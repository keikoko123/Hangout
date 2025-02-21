import express from "express";
import authRouter from "./routes/auth"; // Adjust the path as necessary
import taskRouter from "./routes/task";

const app = express();

app.use(express.json());

app.use("/auth", authRouter);
app.use("/tasks", taskRouter);

app.get("/", (req, res) => {
  res.send("Hello! Welcome to Hangout! UserName (from docker container)");
});

app.listen(8000, () => {
  console.log(
    "Hangout Server1 is running on port 8000 (from docker container)"
  );
});
