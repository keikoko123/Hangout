import { Router, Request, Response, NextFunction } from "express";
import { auth, AuthRequest } from "../middleware/auth";
import { NewUser, users } from "../db/schema";
import { db } from "../db";
import { eq } from "drizzle-orm";
import bcryptjs from "bcryptjs";

const usersRouter = Router();

// Define a custom type for our request handlers
type UserRequestHandler = (
  req: Request | AuthRequest,
  res: Response,
  next: NextFunction
) => void;

// GET all users (admin only)
const getAllUsers: UserRequestHandler = (req: AuthRequest, res, next) => {
  // Check if user is admin (you might want to add an isAdmin field to users table)
  // For now, we'll just return all users
  db.select()
    .from(users)
    .then((allUsers) => {
      // Remove password from response
      const usersWithoutPassword = allUsers.map((user) => {
        const { password, ...userWithoutPassword } = user;
        return userWithoutPassword;
      });

      res.json(usersWithoutPassword);
    })
    .catch(next);
};

// GET user by ID
const getUserById: UserRequestHandler = (req: AuthRequest, res, next) => {
  const userId = req.params.id;

  db.select()
    .from(users)
    .where(eq(users.id, userId))
    .then(([user]) => {
      if (!user) {
        return res.status(404).json({ error: "User not found" });
      }

      // Remove password from response
      const { password, ...userWithoutPassword } = user;

      res.json(userWithoutPassword);
    })
    .catch(next);
};

// GET current user profile
const getCurrentUser: UserRequestHandler = (req: AuthRequest, res, next) => {
  db.select()
    .from(users)
    .where(eq(users.id, req.user!))
    .then(([user]) => {
      if (!user) {
        return res.status(404).json({ error: "User not found" });
      }

      // Remove password from response
      const { password, ...userWithoutPassword } = user;

      res.json(userWithoutPassword);
    })
    .catch(next);
};

// UPDATE user profile
const updateUserProfile: UserRequestHandler = (req: AuthRequest, res, next) => {
  const userId = req.user!;
  const {
    name,
    email,
    bio,
    profileImage,
    mbtiE_I_score,
    mbtiS_N_score,
    mbtiT_F_score,
    mbtiJ_P_score,
    mbtiType,
  } = req.body;

  // Check if email is being changed and if it's already in use
  if (email) {
    db.select()
      .from(users)
      .where(eq(users.email, email))
      .then(([existingUser]) => {
        if (existingUser && existingUser.id !== userId) {
          return res.status(400).json({ error: "Email already in use" });
        }

        // Update user
        db.update(users)
          .set({
            name: name || undefined,
            email: email || undefined,
            bio: bio || undefined,
            profileImage: profileImage || undefined,
            mbtiE_I_score:
              mbtiE_I_score !== undefined ? mbtiE_I_score : undefined,
            mbtiS_N_score:
              mbtiS_N_score !== undefined ? mbtiS_N_score : undefined,
            mbtiT_F_score:
              mbtiT_F_score !== undefined ? mbtiT_F_score : undefined,
            mbtiJ_P_score:
              mbtiJ_P_score !== undefined ? mbtiJ_P_score : undefined,
            mbtiType: mbtiType || undefined,
            updated_at: new Date(),
          })
          .where(eq(users.id, userId))
          .returning()
          .then(([updatedUser]) => {
            // Remove password from response
            const { password, ...userWithoutPassword } = updatedUser;
            res.json(userWithoutPassword);
          })
          .catch(next);
      })
      .catch(next);
  } else {
    // Update user without checking email
    db.update(users)
      .set({
        name: name || undefined,
        email: email || undefined,
        bio: bio || undefined,
        profileImage: profileImage || undefined,
        mbtiE_I_score: mbtiE_I_score !== undefined ? mbtiE_I_score : undefined,
        mbtiS_N_score: mbtiS_N_score !== undefined ? mbtiS_N_score : undefined,
        mbtiT_F_score: mbtiT_F_score !== undefined ? mbtiT_F_score : undefined,
        mbtiJ_P_score: mbtiJ_P_score !== undefined ? mbtiJ_P_score : undefined,
        mbtiType: mbtiType || undefined,
        updated_at: new Date(),
      })
      .where(eq(users.id, userId))
      .returning()
      .then(([updatedUser]) => {
        // Remove password from response
        const { password, ...userWithoutPassword } = updatedUser;
        res.json(userWithoutPassword);
      })
      .catch(next);
  }
};

// UPDATE user password
const updateUserPassword: UserRequestHandler = (
  req: AuthRequest,
  res,
  next
) => {
  const userId = req.user!;
  const { currentPassword, newPassword } = req.body;

  // Get current user
  db.select()
    .from(users)
    .where(eq(users.id, userId))
    .then(([user]) => {
      if (!user) {
        return res.status(404).json({ error: "User not found" });
      }

      // Verify current password
      bcryptjs
        .compare(currentPassword, user.password)
        .then((isMatchPW) => {
          if (!isMatchPW) {
            return res
              .status(400)
              .json({ error: "Current password is incorrect" });
          }

          // Hash new password
          bcryptjs
            .hash(newPassword, 8)
            .then((hashedPassword) => {
              // Update password
              db.update(users)
                .set({
                  password: hashedPassword,
                  updated_at: new Date(),
                })
                .where(eq(users.id, userId))
                .then(() => {
                  res.json({ message: "Password updated successfully" });
                })
                .catch(next);
            })
            .catch(next);
        })
        .catch(next);
    })
    .catch(next);
};

// DELETE user (admin only)
const deleteUser: UserRequestHandler = (req: AuthRequest, res, next) => {
  const userId = req.params.id;

  // Check if user is admin (you might want to add an isAdmin field to users table)
  // For now, we'll just allow deletion
  db.delete(users)
    .where(eq(users.id, userId))
    .then(() => {
      res.json({ message: "User deleted successfully" });
    })
    .catch(next);
};

// Register routes
usersRouter.get("/", auth, getAllUsers);
usersRouter.get("/:id", auth, getUserById);
usersRouter.get("/profile/me", auth, getCurrentUser);
usersRouter.put("/profile", auth, updateUserProfile);
usersRouter.put("/password", auth, updateUserPassword);
usersRouter.delete("/:id", auth, deleteUser);

export default usersRouter;
