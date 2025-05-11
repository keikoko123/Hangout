// import { db } from "../db";
// import { hobbyEvents } from "../db/schema";
// import { convertJsonArrayToHobbyEvents } from "../utils/hobbyEventConverter";
// import * as fs from "fs";
// import * as path from "path";

// /**
//  * Example script to import hobby events from JSON file
//  * 從 JSON 文件導入愛好活動的示例腳本
//  */
// async function importHobbyEvents() {
//   try {
//     // Read JSON file
//     // 讀取 JSON 文件
//     const jsonFilePath = path.resolve(
//       __dirname,
//       "../../../hobby-scraper/parsed_result.json"
//     );
//     const jsonData = JSON.parse(fs.readFileSync(jsonFilePath, "utf8"));

//     console.log(`Found ${jsonData.length} hobby events in JSON file`);
//     console.log(`在 JSON 文件中找到 ${jsonData.length} 個愛好活動`);

//     // Convert JSON data to hobby event objects
//     // 將 JSON 數據轉換為愛好活動對象
//     const hobbyEventObjects = convertJsonArrayToHobbyEvents(jsonData);

//     // Insert into database
//     // 插入數據庫
//     const insertedEvents = await db
//       .insert(hobbyEvents)
//       .values(hobbyEventObjects)
//       .returning();

//     console.log(`Successfully imported ${insertedEvents.length} hobby events`);
//     console.log(`成功導入 ${insertedEvents.length} 個愛好活動`);

//     return insertedEvents;
//   } catch (error) {
//     console.error("Error importing hobby events:", error);
//     console.error("導入愛好活動時出錯:", error);
//     throw error;
//   }
// }

// // Run the import function if this script is executed directly
// // 如果直接執行此腳本，則運行導入函數
// if (require.main === module) {
//   importHobbyEvents()
//     .then(() => process.exit(0))
//     .catch((error) => {
//       console.error(error);
//       process.exit(1);
//     });
// }

// export { importHobbyEvents };
