import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";

export const pool = new Pool({
  // connectionString: process.env.DATABASE_URL,
  connectionString: "postgresql://postgres:test123@db:5432/hangoutdb",
  // connectionString: "postgresql://postgres:test123@db:5432/hangoutdb",
});

// export default drizzle(pool);
export const db = drizzle(pool);
