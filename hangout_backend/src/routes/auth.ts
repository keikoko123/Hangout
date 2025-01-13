import { Router, Request, Response } from "express";
import { db } from "../db";
import { eq } from "drizzle-orm";
import { NewUser, users } from "../db/schema";
import bcryptjs from "bcryptjs";
import jwt from "jsonwebtoken";
import { auth, AuthRequest } from "../middleware/auth";
import { error } from "console";

const authRouter = Router();

interface SignUpBody {
  name: string;
  email: string;
  password: string;
}

interface LoginBody {
  email: string;
  password: string;
}

authRouter.post("/signup", async (req: Request<{}, {}, SignUpBody>, res) => {
  try {
    //get req body
    const { name, email, password } = req.body;
    //check if the user already exists
    const existingUser = await db
      .select()
      .from(users)
      .where(eq(users.email, email));

    if (existingUser.length > 0) {
      res.status(400).json({ error: "User already exists" });
      return;
    }

    //! hash the password
    const hashedPassword = await bcryptjs.hash(password, 8); //8 radnom string
    //create a new user and store in db
    const newUser: NewUser = {
      name,
      email,
      password: hashedPassword,
    };
    const [user] = await db.insert(users).values(newUser).returning();
    res.status(201).json(user);
  } catch (error) {
    res.status(500).json({ error: error });
  }
});

authRouter.post("/login", async (req: Request<{}, {}, LoginBody>, res) => {
  try {
    //get req body
    const { email, password } = req.body;
    //check if the user already exists
    const [existingUser] = await db
      .select()
      .from(users)
      .where(eq(users.email, email));

    if (!existingUser) {
      res.status(400).json({ error: "User with the email doesn't exists" });
      return;
    }

    //! hash the password
    const isMatchPW = await bcryptjs.compare(password, existingUser.password); //8 radnom string

    if (!isMatchPW) {
      res.status(400).json({ error: "Invalid Password" });
      return;
    }

    //! jwt
    const token = jwt.sign({ id: existingUser.id }, "passwordKey");

    res.json({ token, ...existingUser });
  } catch (error) {
    res.status(500).json({ error: error });
  }
});

authRouter.post("/tokenIsValid", async (req, res) => {
  try {
    // 1 get the header
    const token = req.header("x-auth-token");

    if (!token) {
      res.json(false);
      return;
    }

    // 2 verify if the token is valid
    const verified = jwt.verify(token, "passwordKey");

    if (!verified) {
      res.json(false);
      return;
    }

    // 3 get the user data if the token is valid
    const verifiedToken = verified as { id: string };

    const [user] = await db
      .select()
      .from(users)
      .where(eq(users.id, verifiedToken.id));

    if (!user) {
      res.json(false);
      return;
    }

    res.json(true);
  } catch (e) {
    res.status(500).json(false);
  }
});

//app.use("/auth", authRouter);
//! middleware auth
// authRouter.get("/", auth, (req: AuthRequest, res) => {
//   // res.send();
//   res.send("Hey You are routed to AuthPage: " + req.token);
// });

authRouter.get("/", auth, async (req: AuthRequest, res) => {
  try {
    if (!req.user) {
      res.status(401).json({ error: "User not found!" });
      return;
    }

    const [user] = await db.select().from(users).where(eq(users.id, req.user));

    res.json({ ...user, token: req.token });
  } catch (e) {
    res.status(500).json(false);
  }
});

export default authRouter;
