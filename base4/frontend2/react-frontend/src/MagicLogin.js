import React, { useEffect, useState } from "react";
import { Magic } from "magic-sdk";

const magic = new Magic("pk_live_845610B169B276D7");

function MagicLogin() {
  const [user, setUser] = useState(null);
  const [email, setEmail] = useState("");
  const [name, setName] = useState("");
  const [file, setFile] = useState(null);
  const [imageUrl, setImageUrl] = useState(null);
  const [isRegistered, setIsRegistered] = useState(false);

  useEffect(() => {
    (async () => {
      const isLoggedIn = await magic.user.isLoggedIn();
      if (isLoggedIn) {
        const userMetadata = await magic.user.getInfo();
        setUser(userMetadata);

        // Fetch user profile from backend after login (using the email)
        // This is crucial to load existing data from users.json
        fetchUserProfileFromBackend(userMetadata.email);
      }
    })();
  }, []);

  // Function to fetch user profile from the backend
  const fetchUserProfileFromBackend = async (userEmail) => {
    try {
      console.log(`REACT: Attempting to fetch profile for ${userEmail}`);
      const res = await fetch(`https://teamrocket-2.onrender.com/user-profile?email=${userEmail}`);

      if (res.ok) {
        const data = await res.json();
        console.log("REACT: User profile loaded from backend:", data);
        setName(data.name);
        setImageUrl(data.imageUrl);
        setIsRegistered(true);
      } else {
        console.warn("REACT: User profile not found on backend or error:", await res.json());
        setIsRegistered(false); // If profile not found, they are not registered
      }
    } catch (err) {
      console.error("REACT ERROR: Error fetching user profile:", err);
      setIsRegistered(false);
    }
  };


  const handleLogin = async () => {
    try {
      await magic.auth.loginWithEmailOTP({ email });
      const userMetadata = await magic.user.getInfo();
      setUser(userMetadata);

      // After successful login, try to load their profile from backend
      fetchUserProfileFromBackend(userMetadata.email);

    } catch (err) {
      console.error("Login error:", err);
    }
  };

  const uploadToBackend = async () => {
    const formData = new FormData();
    formData.append("file", file);

    try {
      console.log("REACT: Attempting image upload to backend...");
      const res = await fetch("https://teamrocket-2.onrender.com/upload", {
        method: "POST",
        body: formData,
      });

      const data = await res.json();
      if (res.ok && data && data.ipfsHash) { // Ensure response is OK and has ipfsHash
          const ipfsUrl = `https://gateway.pinata.cloud/ipfs/${data.ipfsHash}`;
          console.log("📦 Uploaded to:", ipfsUrl);
          return ipfsUrl;
      } else {
          console.error("❌ REACT: Backend response for upload missing ipfsHash or not ok:", data);
          alert("Image upload failed: " + (data?.error || "Unknown error"));
          return null;
      }
    } catch (err) {
      console.error("❌ REACT ERROR: Error uploading to backend:", err);
      alert("Error during image upload. Check network or backend server.");
      return null;
    }
  };

  const registerIdentity = async (ipfsUrl) => {
    try {
      // CRITICAL: Ensure user is logged in and user.email is available
      if (!user || !user.email) {
        console.error("❌ REACT: User not logged in or email not available for registration.");
        alert("Please log in first before registering your identity.");
        return; // Stop execution if email is missing
      }

      console.log("REACT: Attempting to register identity with backend...");
      const res = await fetch("https://teamrocket-2.onrender.com/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: user.email, // <--- THIS IS THE FIX: INCLUDE THE USER'S EMAIL
          name,
          ipfsHash: ipfsUrl.split("/").pop() // Extract just the hash
        }),
      });

      const data = await res.json();
      if (res.ok) { // Check for a 2xx status code
        console.log("✅ REACT: Identity successfully registered:", data);
        // Update local storage and state for immediate UI reflection
        localStorage.setItem(user.email, JSON.stringify({ name, imageUrl: ipfsUrl }));
        setImageUrl(ipfsUrl);
        setIsRegistered(true);
        alert("✅ Identity successfully registered!");
      } else {
        console.error("❌ REACT: Backend error during registration:", data.error);
        alert("❌ Failed to register identity: " + (data.error || "Unknown error"));
      }
    } catch (err) {
      console.error("❌ REACT ERROR: Error calling backend for registration:", err);
      alert("❌ Error during registration (network/client issue).");
    }
  };

  const handleRegister = async () => {
    if (!name || !file) {
      alert("Please fill in name and upload a file.");
      return;
    }

    const ipfsUrl = await uploadToBackend();
    if (!ipfsUrl) { // Stop if upload failed
      alert("Image upload failed. Cannot proceed with registration.");
      return;
    }

    await registerIdentity(ipfsUrl);
  };

  const handleLogout = async () => {
    try {
      await magic.user.logout();
      setUser(null);
      setEmail("");
      setName("");
      setFile(null);
      setImageUrl(null);
      setIsRegistered(false);
      localStorage.removeItem(user?.email || ''); // Clear relevant local storage data
      console.log("REACT: User logged out successfully.");
    } catch (err) {
      console.error("Logout error:", err);
    }
  };

  if (user) {
    return (
      <div>
        <p><strong>Logged in as:</strong> {user.email}</p>
        <p><strong>Public Address:</strong> {user.publicAddress}</p>

        {isRegistered ? (
          <>
            <h3>Your Registered Identity</h3>
            <p><strong>Name:</strong> {name}</p>
            <p><strong>Uploaded Image:</strong></p>
            {imageUrl && <img src={imageUrl} alt="Uploaded Identity" width="200" />}
            <br /><br />
            {/* Provide option to update identity */}
            <p>Want to update your identity?</p>
             <input
              type="text"
              placeholder="Enter new name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              style={{ padding: "8px", marginBottom: "8px" }}
            /><br />

            <input
              type="file"
              onChange={(e) => setFile(e.target.files[0])}
              style={{ padding: "8px", marginBottom: "8px" }}
            /><br />

            <button onClick={handleRegister} style={{ marginRight: "8px" }}>
              Update Identity
            </button>
            <button onClick={handleLogout}>Logout</button>
          </>
        ) : (
          <>
            <h3>Register Your Identity</h3>
            <input
              type="text"
              placeholder="Enter your name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              style={{ padding: "8px", marginBottom: "8px" }}
            /><br />

            <input
              type="file"
              onChange={(e) => setFile(e.target.files[0])}
              style={{ padding: "8px", marginBottom: "8px" }}
            /><br />

            <button onClick={handleRegister} style={{ marginRight: "8px" }}>
              Register Identity
            </button>
            <button onClick={handleLogout}>Logout</button>
          </>
        )}
      </div>
    );
  }

  return (
    <div>
      <h3>Login with Magic Link</h3>
      <input
        type="email"
        placeholder="Enter your email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        style={{ padding: "8px", marginRight: "8px" }}
      />
      <button onClick={handleLogin}>Login</button>
    </div>
  );
}

export default MagicLogin;