# HKBU2025 FYP Mobile-App Name:  AfterWork / Hangout  
AfterWork is a transformative lifestyle planning app designed to help busy professionals and urban individuals achieve a fulfilling work-life balance through structured personal growth and efficient time management. 

By integrating AI-powered interest discovery, guided hobby development, and smart daily task optimization, the app empowers users to explore new passions, build meaningful skills, and maximize their leisure time. 




# a.Running Environment
#### Standard Client 	
Android / iOS by Flutter	
Minimum Android version: 10
Maximum Android version: 14
SQLite

#### Application Server
JavaScript & TypeScript (Nodejs)
Docker（Linux Containers）

#### Database Server
PostgreSQL
Docker（Linux Containers）




# b. Deployment steps
#### Backend:
STEP 1: install nodejs 
 
STEP 2: use nodejs & npm install TypeScript-libraries (e.g: CMD: npm install ts-node --save-dev, npm i -D drizzle-kit)

STEP 3: all the image will build with docker-compose.yml, please install docker-desktop with https://www.docker.com/products/docker-desktop/

STEP 4: in src folder, CMD: docker compose up --build

STEP 5(optional): TABLES IN PostgreSQL Database is builded in docker with drizzle-kit, if not please use （ npx drizzle-kit push ）with running docker image

Check Database Server by it with psql -U postgres -d hangoutdb

Check Nodejs Server by docker run -p 8000:8000 hangout-backend

Input Initial Hobbies with HobbyObjList.json

Backend Deployment Finished



#### Frontend:
STEP 1: install Dart and flutter with specific version (flutter_windows_3.27.1-stable.zip)

STEP 2: CMD: flutter packages get (in pubspec.yaml）

STEP 3:  Right Click main.dart & Click Build with Debug Mode

Frontend Deployment Finished


# Demo
https://github.com/user-attachments/assets/34c7ff0d-2961-490c-8d30-8d44eada7afd

![AfterWork – Lifestyle Planner An Easy-Plan Easy-Life Platform (1) (2)](https://github.com/user-attachments/assets/fca0ee8b-2c31-45ce-ae6c-5be3129b6604)






