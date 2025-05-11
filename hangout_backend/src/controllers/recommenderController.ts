// import { Request, Response } from "express";
// import {
//   RecommenderService,
//   RecommendationRequest,
// } from "../services/recommenderService";

// export class RecommenderController {
//   static async getRecommendations(req: Request, res: Response) {
//     try {
//       const request: RecommendationRequest = {
//         user_id: req.body.user_id,
//         mbti: req.body.mbti,
//         interests: req.body.interests,
//       };

//       const recommendations = await RecommenderService.getRecommendations(
//         request
//       );
//       res.json(recommendations);
//     } catch (error) {
//       res.status(500).json({ error: "Failed to get recommendations" });
//     }
//   }
// }
