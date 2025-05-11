import {
  Router,
  Request,
  Response,
  RequestHandler,
  NextFunction,
} from "express";
import { auth, AuthRequest } from "../middleware/auth";
import { NewHobby, hobbies } from "../db/schema";
import { db } from "../db";
import { eq, like, and, or, desc, asc, SQL } from "drizzle-orm";

const hobbiesRouter = Router();

// Define a custom type for our request handlers
type HobbyRequestHandler = (
  req: Request | AuthRequest,
  res: Response,
  next: NextFunction
) => void;

// GET all hobbies
const getAllHobbies: HobbyRequestHandler = (req, res, next) => {
  const {
    category,
    subcategory,
    costLevel,
    indoorOutdoor,
    socialLevel,
    ageRange,
    sortBy,
    sortOrder,
  } = req.query;

  // Build the where clause
  const whereClause = [];

  if (category) {
    whereClause.push(eq(hobbies.category, category as string));
  }

  if (subcategory) {
    whereClause.push(eq(hobbies.subcategory, subcategory as string));
  }

  if (costLevel) {
    whereClause.push(eq(hobbies.costLevel, costLevel as string));
  }

  if (indoorOutdoor) {
    whereClause.push(eq(hobbies.indoorOutdoor, indoorOutdoor as string));
  }

  if (socialLevel) {
    whereClause.push(eq(hobbies.socialLevel, socialLevel as string));
  }

  if (ageRange) {
    whereClause.push(eq(hobbies.ageRange, ageRange as string));
  }

  // Execute the query with all conditions
  db.select()
    .from(hobbies)
    .where(whereClause.length > 0 ? and(...whereClause) : undefined)
    .orderBy(
      sortBy === "popularity"
        ? desc(hobbies.popularity)
        : sortBy === "category"
        ? asc(hobbies.category)
        : asc(hobbies.name)
    )
    .then((allHobbies) => {
      res.json(allHobbies);
    })
    .catch(next);
};

// GET hobby by ID
const getHobbyById: HobbyRequestHandler = (req, res, next) => {
  const hobbyId = req.params.id;

  db.select()
    .from(hobbies)
    .where(eq(hobbies.id, hobbyId))
    .then(([hobby]) => {
      if (!hobby) {
        return res.status(404).json({ error: "Hobby not found" });
      }
      res.json(hobby);
    })
    .catch(next);
};

// GET hobbies by MBTI compatibility
const getHobbiesByMBTI: HobbyRequestHandler = (req, res, next) => {
  const mbtiType = req.params.mbtiType;

  // Extract MBTI dimensions from the type (e.g., "INTJ" -> I, N, T, J)
  const e_i = mbtiType.charAt(0) === "E" ? 100 : -100;
  const s_n = mbtiType.charAt(1) === "N" ? 100 : -100;
  const t_f = mbtiType.charAt(2) === "F" ? 100 : -100;
  const j_p = mbtiType.charAt(3) === "P" ? 100 : -100;

  // Find hobbies with matching MBTI scores
  db.select()
    .from(hobbies)
    .where(
      and(
        or(
          eq(hobbies.mbtiE_I, e_i.toString()),
          eq(hobbies.mbtiE_I, "0") // "both" option
        ),
        or(
          eq(hobbies.mbtiS_N, s_n.toString()),
          eq(hobbies.mbtiS_N, "0") // "both" option
        ),
        or(
          eq(hobbies.mbtiT_F, t_f.toString()),
          eq(hobbies.mbtiT_F, "0") // "both" option
        ),
        or(
          eq(hobbies.mbtiJ_P, j_p.toString()),
          eq(hobbies.mbtiJ_P, "0") // "both" option
        )
      )
    )
    .orderBy(desc(hobbies.popularity))
    .then((compatibleHobbies) => {
      res.json(compatibleHobbies);
    })
    .catch(next);
};

// CREATE new hobby (admin only)
const createHobby: HobbyRequestHandler = (req: AuthRequest, res, next) => {
  const newHobby: NewHobby = req.body;

  db.insert(hobbies)
    .values(newHobby)
    .returning()
    .then(([hobby]) => {
      res.status(201).json(hobby);
    })
    .catch(next);
};

// UPDATE hobby (admin only)
const updateHobby: HobbyRequestHandler = (req: AuthRequest, res, next) => {
  const hobbyId = req.params.id;
  const updatedData = req.body;

  db.update(hobbies)
    .set({
      ...updatedData,
      updatedAt: new Date(),
    })
    .where(eq(hobbies.id, hobbyId))
    .returning()
    .then(([updatedHobby]) => {
      if (!updatedHobby) {
        return res.status(404).json({ error: "Hobby not found" });
      }
      res.json(updatedHobby);
    })
    .catch(next);
};

// DELETE hobby (admin only)
const deleteHobby: HobbyRequestHandler = (req: AuthRequest, res, next) => {
  const hobbyId = req.params.id;

  db.delete(hobbies)
    .where(eq(hobbies.id, hobbyId))
    .then(() => {
      res.json({ message: "Hobby deleted successfully" });
    })
    .catch(next);
};

// Register routes
hobbiesRouter.get("/", getAllHobbies);
hobbiesRouter.get("/:id", getHobbyById);
hobbiesRouter.get("/mbti/:mbtiType", getHobbiesByMBTI);
hobbiesRouter.post("/", auth, createHobby);
hobbiesRouter.put("/:id", auth, updateHobby);
hobbiesRouter.delete("/:id", auth, deleteHobby);

export default hobbiesRouter;
