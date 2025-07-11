import React from "react";
import MagicLogin from "./MagicLogin";

function App() {
  return (
    <div style={{ padding: "2rem", fontFamily: "Arial, sans-serif", maxWidth: "600px", margin: "0 auto" }}>
      <h1 style={{ textAlign: "center", color: "#333" }}>Migrant Identity DApp</h1>
      <MagicLogin />
    </div>
  );
}

export default App;