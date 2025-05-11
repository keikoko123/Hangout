<<<<<<< HEAD
# HKBU2025 FYP Mobile-App 
# Name:  AfterWork / Hangout  

# a.Running Environment
=======
# Hangout
 HKBU2025-FYP

運行版本
>>>>>>> 3eed6c05b6db1f6e3c5c63ce5d2b4cca970beb45
flutter_windows_3.27.1-stable.zip
nodejs 20
psql 15

<<<<<<< HEAD
# b. Deployment steps
# Backend:
STEP 1: install nodejs 
 
STEP 2: use nodejs & npm install TypeScript-libraries (e.g: CMD: npm install ts-node --save-dev, npm i -D drizzle-kit)

STEP 3: all the image will build with docker-compose.yml, please install docker-desktop with https://www.docker.com/products/docker-desktop/

STEP 4: in src folder, CMD: docker compose up --build

STEP 5(optional): TABLES IN PostgreSQL Database is builded in docker with drizzle-kit, if not please use （ npx drizzle-kit push ）with running docker image

Check Database Server by it with psql -U postgres -d hangoutdb

Check Nodejs Server by docker run -p 8000:8000 hangout-backend

Input Initial Hobbies with HobbyObjList.json

# Backend Deployment Finished



# Frontend:
STEP 1: install Dart and flutter with specific version (flutter_windows_3.27.1-stable.zip)

STEP 2: CMD: flutter packages get (in pubspec.yaml）

STEP 3:  Right Click main.dart & Click Build with Debug Mode

# Frontend Deployment Finished
