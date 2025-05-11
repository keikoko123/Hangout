import {
  pgTable,
  uuid,
  text,
  timestamp,
  integer,
  boolean,
  jsonb,
} from "drizzle-orm/pg-core";
import { relations } from "drizzle-orm";

// Define table declarations first
export const users = pgTable("users", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull(),
  email: text("email").notNull().unique(),
  password: text("password").notNull(),

  profileImage: text("profile_image"),
  bio: text("bio"),

  gameCoin: integer("game_coin").notNull().default(0),

  // MBTI scores for users
  mbtiE_I_score: integer("mbti_e_i_score").notNull().default(0), // -100 to 100, negative for introvert, positive for extrovert
  mbtiS_N_score: integer("mbti_s_n_score").notNull().default(0), // -100 to 100, negative for sensing, positive for intuition
  mbtiT_F_score: integer("mbti_t_f_score").notNull().default(0), // -100 to 100, negative for thinking, positive for feeling
  mbtiJ_P_score: integer("mbti_j_p_score").notNull().default(0), // -100 to 100, negative for judging, positive for perceiving
  mbtiType: text("mbti_type"), // The four-letter MBTI type (e.g., "INTJ")

  created_at: timestamp("created_at").defaultNow(),
  updated_at: timestamp("updated_at").defaultNow(),
});

export const hobbies = pgTable("hobbies", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: text("name").notNull(),
  description: text("description"),
  category: text("category").notNull(),
  subcategory: text("subcategory"),
  icon: text("icon"),
  // difficulty: text("difficulty").notNull().default("medium"), // easy, medium, hard
  equipment: jsonb("equipment"), // JSON array of required equipment
  costLevel: text("cost_level").notNull().default("medium"), // low, medium, high
  indoorOutdoor: text("indoor_outdoor").notNull().default("both"), // indoor, outdoor, both
  socialLevel: text("social_level").notNull().default("medium"), // solo, small group, large group
  ageRange: text("age_range").notNull().default("all"), // children, teens, adults, seniors, all
  popularity: integer("popularity").notNull().default(0), // Popularity score
  imageUrl: text("image_url"), // URL to hobby image

  // MBTI scores for users
  mbtiE_I_score: integer("mbti_e_i_score").notNull().default(0), // -100 to 100, negative for introvert, positive for extrovert
  mbtiS_N_score: integer("mbti_s_n_score").notNull().default(0), // -100 to 100, negative for sensing, positive for intuition
  mbtiT_F_score: integer("mbti_t_f_score").notNull().default(0), // -100 to 100, negative for thinking, positive for feeling
  mbtiJ_P_score: integer("mbti_j_p_score").notNull().default(0), // -100 to 100, negative for judging, positive for perceiving

  // MBTI-related properties
  mbtiE_I: text("mbti_e_i").notNull().default("both"), // extrovert, introvert, both
  mbtiS_N: text("mbti_s_n").notNull().default("both"), // sensing, intuition, both
  mbtiT_F: text("mbti_t_f").notNull().default("both"), // thinking, feeling, both
  mbtiJ_P: text("mbti_j_p").notNull().default("both"), // judging, perceiving, both

  // MBTI-related properties as scores
  mbtiCompatibility: jsonb("mbti_compatibility"), // JSON array of compatible MBTI types with scores

  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export const userHobbies = pgTable("user_hobbies", {
  id: uuid("id").primaryKey().defaultRandom(),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  hobbyId: uuid("hobby_id")
    .notNull()
    .references(() => hobbies.id, { onDelete: "cascade" }),
  skillLevel: text("skill_level").notNull().default("beginner"), // beginner, intermediate, advanced
  level: integer("level").notNull().default(1), // User's level in this hobby (1-100)
  experiencePoints: integer("experience_points").notNull().default(0), // XP earned in this hobby
  isFavorite: boolean("is_favorite").notNull().default(false),
  lastPracticed: timestamp("last_practiced"), // When the user last engaged in this hobby
  notes: text("notes"), // Personal notes about this hobby
  goals: jsonb("goals"), // JSON array of goals related to this hobby
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export const tasks = pgTable("tasks", {
  id: uuid("id").primaryKey().defaultRandom(),
  title: text("title").notNull(),
  description: text("description").notNull(),
  hexColor: text("hex_color").notNull(),
  uid: uuid("uid")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  dueAt: timestamp("due_at").$defaultFn(
    () => new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
  ),
  isCompleted: boolean("is_completed").notNull().default(false),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export const hobbyEvents = pgTable("hobby_events", {
  id: uuid("id").primaryKey().defaultRandom(),
  title: text("title").notNull(),
  description: text("description").notNull(),
  difficulty: text("difficulty").notNull().default("medium"), // easy, medium, hard
  // url: text("url").notNull(),
  location: text("location").notNull(),
  organizer: text("organizer").notNull(),
  category: text("category").notNull(),
  tags: text("tags").notNull(),
  quotaAmount: integer("quota_amount").notNull().default(20),
  JoinedAmount: integer("joined_amount").notNull().default(0),
  hostDateTime: timestamp("host_date_time").notNull(),
  duration: integer("duration").notNull(),
  status: text("status").notNull().default("upcoming"),
  price: integer("price").notNull().default(0),
  registrationDeadline: timestamp("registration_deadline"),
  hobbyId: uuid("hobby_id").references(() => hobbies.id, {
    onDelete: "set null",
  }),
  hostId: uuid("host_id").references(() => users.id, { onDelete: "set null" }),
  isPost: boolean("is_post").notNull().default(false), // Indicates if this is a post rather than an event
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export const eventParticipants = pgTable("event_participants", {
  id: uuid("id").primaryKey().defaultRandom(),
  eventId: uuid("event_id")
    .notNull()
    .references(() => hobbyEvents.id, { onDelete: "cascade" }),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  status: text("status").notNull().default("registered"), // registered, attended, cancelled
  paymentStatus: text("payment_status").notNull().default("pending"), // pending, paid, refunded
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export const comments = pgTable("comments", {
  id: uuid("id").primaryKey().defaultRandom(),
  content: text("content").notNull(),
  eventId: uuid("event_id")
    .notNull()
    .references(() => hobbyEvents.id, { onDelete: "cascade" }),
  userId: uuid("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  parentId: uuid("parent_id"),
  likes: integer("likes").notNull().default(0),
  isEdited: boolean("is_edited").notNull().default(false),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

// Define types
export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;

export type Hobby = typeof hobbies.$inferSelect;
export type NewHobby = typeof hobbies.$inferInsert;

export type UserHobby = typeof userHobbies.$inferSelect;
export type NewUserHobby = typeof userHobbies.$inferInsert;

export type Task = typeof tasks.$inferSelect;
export type NewTask = typeof tasks.$inferInsert;

export type HobbyEvent = typeof hobbyEvents.$inferSelect;
export type NewHobbyEvent = typeof hobbyEvents.$inferInsert;

export type EventParticipant = typeof eventParticipants.$inferSelect;
export type NewEventParticipant = typeof eventParticipants.$inferInsert;

export type Comment = typeof comments.$inferSelect;
export type NewComment = typeof comments.$inferInsert;

// Define relations after all tables are defined
export const usersRelations = relations(users, ({ many }) => ({
  tasks: many(tasks),
  hobbies: many(userHobbies),
  events: many(eventParticipants),
  comments: many(comments),
}));

export const hobbiesRelations = relations(hobbies, ({ many }) => ({
  users: many(userHobbies),
  events: many(hobbyEvents),
}));

export const userHobbiesRelations = relations(userHobbies, ({ one }) => ({
  user: one(users, {
    fields: [userHobbies.userId],
    references: [users.id],
  }),
  hobby: one(hobbies, {
    fields: [userHobbies.hobbyId],
    references: [hobbies.id],
  }),
}));

export const tasksRelations = relations(tasks, ({ one }) => ({
  user: one(users, {
    fields: [tasks.uid],
    references: [users.id],
  }),
}));

export const hobbyEventsRelations = relations(hobbyEvents, ({ one, many }) => ({
  hobby: one(hobbies, {
    fields: [hobbyEvents.hobbyId],
    references: [hobbies.id],
  }),
  host: one(users, {
    fields: [hobbyEvents.hostId],
    references: [users.id],
  }),
  participants: many(eventParticipants),
  comments: many(comments),
}));

export const eventParticipantsRelations = relations(
  eventParticipants,
  ({ one }) => ({
    event: one(hobbyEvents, {
      fields: [eventParticipants.eventId],
      references: [hobbyEvents.id],
    }),
    user: one(users, {
      fields: [eventParticipants.userId],
      references: [users.id],
    }),
  })
);

export const commentsRelations = relations(comments, ({ one, many }) => ({
  event: one(hobbyEvents, {
    fields: [comments.eventId],
    references: [hobbyEvents.id],
  }),
  user: one(users, {
    fields: [comments.userId],
    references: [users.id],
  }),
  parent: one(comments, {
    fields: [comments.parentId],
    references: [comments.id],
  }),
  replies: many(comments),
}));
