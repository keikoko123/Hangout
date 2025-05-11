import axios, { AxiosError } from "axios";
import axiosRetry from "axios-retry";

const RECOMMENDER_SERVICE_URL =
  process.env.RECOMMENDER_SERVICE_URL || "http://localhost:8001";

// 配置axios重试
axiosRetry(axios, {
  retries: 3,
  retryDelay: axiosRetry.exponentialDelay,
  retryCondition: (error: AxiosError) => {
    return axiosRetry.isNetworkOrIdempotentRequestError(error);
  },
});

export interface RecommendationRequest {
  user_id: number;
  mbti: string;
  interests: string[];
  method?: string; // 添加方法参数，可选
}

export interface RecommendationResponse {
  user_id: number;
  recommendations: Array<{
    id: number;
    name: string;
    description: string;
    mbti_attributes: string[];
    hobby_attributes: string[];
  }>;
  method_used: string;
  confidence_scores: number[];
  created_at: string;
}

export class RecommenderService {
  private static instance: RecommenderService;
  private isHealthy: boolean = true;

  private constructor() {}

  static getInstance(): RecommenderService {
    if (!RecommenderService.instance) {
      RecommenderService.instance = new RecommenderService();
    }
    return RecommenderService.instance;
  }

  async checkHealth(): Promise<boolean> {
    try {
      await axios.get(`${RECOMMENDER_SERVICE_URL}/health`);
      this.isHealthy = true;
      return true;
    } catch (error) {
      this.isHealthy = false;
      console.error("推荐服务健康检查失败:", error);
      return false;
    }
  }

  async getRecommendations(
    request: RecommendationRequest
  ): Promise<RecommendationResponse> {
    if (!this.isHealthy) {
      const isHealthy = await this.checkHealth();
      if (!isHealthy) {
        throw new Error("推荐服务不可用");
      }
    }

    try {
      // 使用正确的API端点
      const response = await axios.post(
        `${RECOMMENDER_SERVICE_URL}/api/recommendations`,
        request,
        {
          timeout: 5000, // 5秒超时
        }
      );
      return response.data;
    } catch (error) {
      if (axios.isAxiosError(error)) {
        console.error("网络错误:", error.message);
        // 重置健康状态，下次请求时重新检查
        this.isHealthy = false;
      } else {
        console.error("获取推荐失败:", error);
      }
      throw new Error("获取推荐失败");
    }
  }

  // 添加评估端点调用方法
  async evaluateRecommendations(): Promise<any> {
    try {
      const response = await axios.get(
        `${RECOMMENDER_SERVICE_URL}/api/recommendations/evaluate`,
        {
          timeout: 10000, // 10秒超时
        }
      );
      return response.data;
    } catch (error) {
      console.error("评估推荐系统失败:", error);
      throw new Error("评估推荐系统失败");
    }
  }
}
