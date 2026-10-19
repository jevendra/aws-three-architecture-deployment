const express = require("express");
const app = express();
const PORT = Number(process.env.PORT || 3000);
const BACKEND_URL = process.env.BACKEND_URL || "http://127.0.0.1:5000";
app.set("view engine", "ejs");
app.set("views", __dirname + "/views");
app.use(express.urlencoded({ extended: false, limit: "20kb" }));
app.use(express.static(__dirname + "/public"));

app.get("/", (_req, res) => res.render("index", { error: null, formData: {} }));
app.post("/submit", async (req, res) => {
  const formData = {
    name: String(req.body.name || "").trim(),
    email: String(req.body.email || "").trim(),
    message: String(req.body.message || "").trim()
  };
  if (!formData.name || !formData.email || !formData.message) {
    return res.status(400).render("index", { error: "Please fill in every field.", formData });
  }
  try {
    const upstream = await fetch(`${BACKEND_URL}/api/submit`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(formData),
      signal: AbortSignal.timeout(8000)
    });
    const result = await upstream.json().catch(() => ({}));
    if (!upstream.ok) {
      return res.status(upstream.status).render("index", {
        error: result.error || "Backend could not process the request.", formData
      });
    }
    return res.redirect(303, "/success");
  } catch (err) {
    console.error("Backend request failed:", err.message);
    return res.status(502).render("index", {
      error: "Cannot reach the Flask backend. Check BACKEND_URL and network rules.", formData
    });
  }
});
app.get("/success", (_req, res) => res.render("success"));
app.get("/health", (_req, res) => res.json({status:"ok", service:"express-frontend"}));
app.listen(PORT, "0.0.0.0", () => console.log(`Express listening on ${PORT}; backend=${BACKEND_URL}`));
