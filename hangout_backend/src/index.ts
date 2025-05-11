import express from "express";
import authRouter from "./routes/auth"; // Adjust the path as necessary
import taskRouter from "./routes/task";
import hobbiesRouter from "./routes/hobbies";
import usersRouter from "./routes/users";
import hobbyEventsRouter from "./routes/hobbyEvents";

const app = express();

app.use(express.json());

// http://localhost:8000/auth/login
app.use("/auth", authRouter);

// http://localhost:8000/tasks/
app.use("/tasks", taskRouter);

// http://localhost:8000/hobbies/
app.use("/hobbies", hobbiesRouter);

// http://localhost:8000/users/
app.use("/users", usersRouter);

// http://localhost:8000/events/
app.use("/events", hobbyEventsRouter);

// http://localhost:8000/
app.get("/", (req, res) => {
  res.send("Hello! Welcome to Hangout! UserName (from docker container)");
});

app.listen(8000, () => {
  console.log(
    "Hangout Server1 is running on port 8000 (from docker container)"
  );
});
