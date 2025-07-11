// src/pinata.js

export const uploadToPinata = async (file) => {
    const data = new FormData();
    data.append("file", file);
  
    try {
      const res = await fetch("https://api.pinata.cloud/pinning/pinFileToIPFS", {
        method: "POST",
        headers: {
          pinata_api_key: "fc541691c2d472878969", // 🔁 Replace with actual key
          pinata_secret_api_key: "eec13b97bed4ef5d83f1a1bace992349d967bf6c8c6752262b174affd72b7023", // 🔁 Replace with actual secret
        },
        body: data,
      });
  
      if (!res.ok) {
        throw new Error(`Pinata upload failed: ${res.statusText}`);
      }
  
      const result = await res.json();
      console.log("📦 IPFS Hash:", result.IpfsHash);
      return result.IpfsHash;
    } catch (error) {
      console.error("❌ Error uploading to Pinata:", error);
      return null;
    }
  };