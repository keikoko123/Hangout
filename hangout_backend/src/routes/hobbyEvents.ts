import { Router, Request, Response, NextFunction } from "express";
import { auth, AuthRequest } from "../middleware/auth";
import { NewHobbyEvent, hobbyEvents, eventParticipants } from "../db/schema";
import { db } from "../db";
import { eq, and, or, desc, asc, sql } from "drizzle-orm";

const hobbyEventsRouter = Router();

// Define a custom type for our request handlers
type HobbyEventRequestHandler = (
  req: Request | AuthRequest,
  res: Response,
  next: NextFunction
) => void;

// GET all hobby events
const getAllHobbyEvents: HobbyEventRequestHandler = (req, res, next) => {
  db.select()
    .from(hobbyEvents)
    .orderBy(desc(hobbyEvents.createdAt))
    .then((allEvents) => {
      res.json(allEvents);
    })
    .catch(next);
};

// GET hobby event by ID
const getHobbyEventById: HobbyEventRequestHandler = (req, res, next) => {
  const eventId = req.params.id;

  db.select()
    .from(hobbyEvents)
    .where(eq(hobbyEvents.id, eventId))
    .then(([event]) => {
      if (!event) {
        return res.status(404).json({ error: "Event not found" });
      }
      res.json(event);
    })
    .catch(next);
};

// GET hobby events by host
const getHobbyEventsByHost: HobbyEventRequestHandler = (
  req: AuthRequest,
  res,
  next
) => {
  const hostId = req.params.hostId || req.user;

  db.select()
    .from(hobbyEvents)
    .where(eq(hobbyEvents.hostId, hostId!))
    .orderBy(desc(hobbyEvents.createdAt))
    .then((events) => {
      res.json(events);
    })
    .catch(next);
};

// GET hobby events by hobby
const getHobbyEventsByHobby: HobbyEventRequestHandler = (req, res, next) => {
  const hobbyId = req.params.hobbyId;

  db.select()
    .from(hobbyEvents)
    .where(eq(hobbyEvents.hobbyId, hobbyId))
    .orderBy(desc(hobbyEvents.createdAt))
    .then((events) => {
      res.json(events);
    })
    .catch(next);
};

// CREATE a new hobby event
const createHobbyEvent: HobbyEventRequestHandler = (
  req: AuthRequest,
  res,
  next
) => {
  const {
    title,
    description,
    difficulty,
    location,
    organizer,
    category,
    tags,
    quotaAmount,
    hostDateTime,
    duration,
    status,
    price,
    registrationDeadline,
    hobbyId,
    isPost,
  } = req.body;

  const newEvent: NewHobbyEvent = {
    title,
    description,
    difficulty: difficulty || "medium",
    location,
    organizer,
    category,
    tags,
    quotaAmount: quotaAmount || 20,
    JoinedAmount: 0,
    hostDateTime: new Date(hostDateTime),
    duration,
    status: status || "upcoming",
    price: price || 0,
    registrationDeadline: registrationDeadline
      ? new Date(registrationDeadline)
      : undefined,
    hobbyId,
    hostId: req.user,
    isPost: isPost || false,
  };

  db.insert(hobbyEvents)
    .values(newEvent)
    .returning()
    .then(([event]) => {
      res.status(201).json(event);
    })
    .catch(next);
};

// UPDATE a hobby event
const updateHobbyEvent: HobbyEventRequestHandler = (
  req: AuthRequest,
  res,
  next
) => {
  const eventId = req.params.id;
  const updateData = req.body;

  // Convert date strings to Date objects if present
  if (updateData.hostDateTime) {
    updateData.hostDateTime = new Date(updateData.hostDateTime);
  }
  if (updateData.registrationDeadline) {
    updateData.registrationDeadline = new Date(updateData.registrationDeadline);
  }

  // First check if the authenticated user is the host of the event
  db.select()
    .from(hobbyEvents)
    .where(eq(hobbyEvents.id, eventId))
    .then(([event]) => {
      if (!event) {
        res.status(404).json({ error: "Event not found" });
        return null; // Return null to skip the next then block
      }

      // Check if user is host of the event
      if (event.hostId !== req.user) {
        res
          .status(403)
          .json({ error: "You are not authorized to update this event" });
        return null; // Return null to skip the next then block
      }

      // Update the event
      return db
        .update(hobbyEvents)
        .set({
          ...updateData,
          updatedAt: new Date(),
        })
        .where(eq(hobbyEvents.id, eventId))
        .returning();
    })
    .then((result) => {
      if (result && result.length > 0) {
        res.json(result[0]);
      }
    })
    .catch(next);
};

// DELETE a hobby event
const deleteHobbyEvent: HobbyEventRequestHandler = (
  req: AuthRequest,
  res,
  next
) => {
  const eventId = req.params.id;

  // First check if the authenticated user is the host of the event
  db.select()
    .from(hobbyEvents)
    .where(eq(hobbyEvents.id, eventId))
    .then(([event]) => {
      if (!event) {
        res.status(404).json({ error: "Event not found" });
        return null; // Return null to skip the next then block
      }

      // Check if user is host of the event
      if (event.hostId !== req.user) {
        res
          .status(403)
          .json({ error: "You are not authorized to delete this event" });
        return null; // Return null to skip the next then block
      }

      // Delete the event
      return db.delete(hobbyEvents).where(eq(hobbyEvents.id, eventId));
    })
    .then((result) => {
      if (result !== null) {
        res.json({ message: "Event deleted successfully" });
      }
    })
    .catch(next);
};

// Register a user to an event
const registerToEvent: HobbyEventRequestHandler = (
  req: AuthRequest,
  res,
  next
) => {
  const eventId = req.params.id;
  const userId = req.user!;

  // Check if event exists and has space
  db.select()
    .from(hobbyEvents)
    .where(eq(hobbyEvents.id, eventId))
    .then(([event]) => {
      if (!event) {
        throw new Error("Event not found");
      }

      if (event.JoinedAmount >= event.quotaAmount) {
        throw new Error("Event is already full");
      }

      // Check if user is already registered
      return db
        .select()
        .from(eventParticipants)
        .where(
          and(
            eq(eventParticipants.eventId, eventId),
            eq(eventParticipants.userId, userId)
          )
        );
    })
    .then((existingRegistration) => {
      if (existingRegistration.length > 0) {
        throw new Error("You are already registered for this event");
      }

      // Register user to event
      return db
        .insert(eventParticipants)
        .values({
          eventId,
          userId,
          status: "registered",
          paymentStatus: "pending",
        })
        .returning();
    })
    .then(([registration]) => {
      // Increment JoinedAmount
      return db
        .update(hobbyEvents)
        .set({
          JoinedAmount: sql`${hobbyEvents.JoinedAmount} + 1`,
        })
        .where(eq(hobbyEvents.id, eventId))
        .returning();
    })
    .then(([updatedEvent]) => {
      res.status(201).json({
        message: "Successfully registered to event",
        event: updatedEvent,
      });
    })
    .catch((error) => {
      res.status(400).json({ error: error.message });
    });
};

// Unregister from an event
const unregisterFromEvent: HobbyEventRequestHandler = (
  req: AuthRequest,
  res,
  next
) => {
  const eventId = req.params.id;
  const userId = req.user!;

  // Check if registration exists
  db.select()
    .from(eventParticipants)
    .where(
      and(
        eq(eventParticipants.eventId, eventId),
        eq(eventParticipants.userId, userId)
      )
    )
    .then((registrations) => {
      if (registrations.length === 0) {
        throw new Error("You are not registered for this event");
      }

      // Delete registration
      return db
        .delete(eventParticipants)
        .where(
          and(
            eq(eventParticipants.eventId, eventId),
            eq(eventParticipants.userId, userId)
          )
        );
    })
    .then(() => {
      // Decrement JoinedAmount
      return db
        .update(hobbyEvents)
        .set({
          JoinedAmount: sql`GREATEST(${hobbyEvents.JoinedAmount} - 1, 0)`,
        })
        .where(eq(hobbyEvents.id, eventId))
        .returning();
    })
    .then(([updatedEvent]) => {
      res.json({
        message: "Successfully unregistered from event",
        event: updatedEvent,
      });
    })
    .catch((error) => {
      res.status(400).json({ error: error.message });
    });
};

// Get registered events for a user
const getUserRegisteredEvents: HobbyEventRequestHandler = (
  req: AuthRequest,
  res,
  next
) => {
  const userId = req.user!;

  db.select({
    event: hobbyEvents,
    status: eventParticipants.status,
    paymentStatus: eventParticipants.paymentStatus,
  })
    .from(eventParticipants)
    .innerJoin(hobbyEvents, eq(eventParticipants.eventId, hobbyEvents.id))
    .where(eq(eventParticipants.userId, userId))
    .orderBy(desc(hobbyEvents.hostDateTime))
    .then((registeredEvents) => {
      res.json(registeredEvents);
    })
    .catch(next);
};

// Register routes
hobbyEventsRouter.get("/", getAllHobbyEvents);
hobbyEventsRouter.get("/hosted", auth, getHobbyEventsByHost);
hobbyEventsRouter.get("/registered", auth, getUserRegisteredEvents);
hobbyEventsRouter.get("/hobby/:hobbyId", getHobbyEventsByHobby);
hobbyEventsRouter.get("/host/:hostId", getHobbyEventsByHost);
hobbyEventsRouter.get("/:id", getHobbyEventById);
hobbyEventsRouter.post("/", auth, createHobbyEvent);
hobbyEventsRouter.put("/:id", auth, updateHobbyEvent);
hobbyEventsRouter.delete("/:id", auth, deleteHobbyEvent);
hobbyEventsRouter.post("/:id/register", auth, registerToEvent);
hobbyEventsRouter.post("/:id/unregister", auth, unregisterFromEvent);

export default hobbyEventsRouter;
