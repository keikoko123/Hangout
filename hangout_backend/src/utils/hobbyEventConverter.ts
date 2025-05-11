// import { NewHobbyEvent } from "../db/schema";

// /**
//  * Converts JSON data to a hobby event object for Drizzle ORM
//  * 將 JSON 數據轉換為 Drizzle ORM 的愛好活動對象
//  *
//  * @param jsonData - The JSON data to convert JSON 數據
//  * @returns A hobby event object 愛好活動對象
//  */
// export function convertJsonToHobbyEvent(jsonData: any): NewHobbyEvent {
//   return {
//     id: jsonData.id,
//     title: jsonData.title,
//     description: jsonData.description,
//     url: jsonData.url,
//     location: jsonData.location,
//     organizer: jsonData.organizer,
//     category: jsonData.category,
//     tags: jsonData.tags,
//   };
// }

// /**
//  * Converts an array of JSON data to hobby event objects
//  * 將 JSON 數據數組轉換為愛好活動對象數組
//  *
//  * @param jsonArray - The array of JSON data to convert JSON 數據數組
//  * @returns An array of hobby event objects 愛好活動對象數組
//  */
// export function convertJsonArrayToHobbyEvents(
//   jsonArray: any[]
// ): NewHobbyEvent[] {
//   return jsonArray.map((item) => convertJsonToHobbyEvent(item));
// }

// /**
//  * Example usage:
//  *
//  * import { convertJsonArrayToHobbyEvents } from './utils/hobbyEventConverter';
//  * import { db } from '../db';
//  * import { hobbyEvents } from '../db/schema';
//  *
//  * // Load JSON data
//  * const jsonData = require('../../hobby-scraper/parsed_result.json');
//  *
//  * // Convert to hobby event objects
//  * const hobbyEventObjects = convertJsonArrayToHobbyEvents(jsonData);
//  *
//  * // Insert into database
//  * const insertedEvents = await db.insert(hobbyEvents).values(hobbyEventObjects).returning();
//  */
