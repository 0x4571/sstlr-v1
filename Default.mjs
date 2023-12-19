// SStlr V2 discord (fastest spoofer): https://discord.gg/Wn93B3yyhY
// Open-sourced as of 10/11/2023 - It was a pleasure to work on this for everyone :)

/*

SPECIAL THANKS:

- <@734235514495828000> (annony12) -> fixed it only spoofing a few animations per try (Removed Break check)

*/

import fetch from 'node-fetch';
import Express from 'express';
import bodyParser from 'body-parser';
import noblox from 'noblox.js';
import fs from 'fs';
import path from 'path';
import {fileURLToPath} from 'url';

const statusFilePath = path.join(path.dirname(fileURLToPath(import.meta.url)), '/STATUS.txt')
const statusContents = fs.readFileSync(statusFilePath, 'utf8');

let debug = false

if (statusContents.match(/ENABLE_DEBUG_MODE/g)) {
  debug = true 
}

const mainApp = Express();
const secApp = Express();

let cookie = null

const content = statusContents.split('\n')

const cookieRegex = /COOKIE=(.*)/;

for (let i = 0; i < content.length; i++) {
  const matchCookie = content[i].match(cookieRegex);

  if (matchCookie) {
    cookie = matchCookie[1];
  }
}

console.log("\"! uwu\"")

const nameTab = ["Oliver", "Ethan", "Ava", "Sophia", "Mia", "Liam", "Isabella", "Charlotte", "Amelia", "Harper", "Emma", "Noah", "William", "James", "Logan", "Lucas", "Alexander", "Elijah", "Benjamin", "Michael", "Daniel", "Matthew", "Emily", "Madison", "Abigail", "Ella", "Grace", "Chloe", "Avery", "Lily", "Jackson", "Evelyn", "Mason", "Sofia", "Eleanor", "Aiden", "Hazel", "Aria", "Scarlett", "Grayson", "Luna", "Mila", "Lillian", "Penelope", "Victoria", "Leah", "Natalie", "Audrey", "Zoe", "Stella", "Lila",
  "Aaliyah", "Aarav", "Adalyn", "Adam", "Adeline", "Adrian", "Ainsley", "Alaina", "Alan", "Alayna", "Alden", "Alec", "Alejandra", "Alexandra", "Alexia", "Alfred", "Ali", "Alice", "Alina", "Alison", "Allan", "Allyson", "Alma", "Alvin", "Alyssa", "Amara", "Amari", "Amina", "Amir", "Anastasia", "Anderson", "Andres", "Andy", "Angel", "Angela", "Angelina", "Angelo", "Anika", "Aniyah", "Ann", "Anna", "Anne", "Annie", "Anthony", "Antonio", "Arabella", "Ari", "Aria", "Ariah", "Ariana", "Ariel", "Ariella", "Arlo", "Arturo", "Arya", "Ash", "Asher", "Ashlyn", "Ashton", "Aspen", "Astrid", "Atlas", "Atticus", "Aubree", "Aubrey", "August", "Augustus", "Aurora", "Austin", "Autumn", "Ava", "Avery", "Axel", "Ayden", "Ayla", "Bailey", "Barbara", "Barrett", "Beatrice"]

const endpoints = {
    assetDelivery: id => `https://assetdelivery.roblox.com/v1/asset/?id=${id}`,
    publish: (title, description, groupId) =>
        'https://www.roblox.com/ide/publish/uploadnewanimation' +
        '?assetTypeName=Animation' +
        `&name=${encodeURIComponent(title)}` +
        `&description=${encodeURIComponent(description)}` +
        '&AllID=1' +
        '&ispublic=False' +
        '&allowComments=True' +
        '&isGamesAsset=False' +
        (groupId != null ? `&groupId=${groupId}` : '')
};

const remapped = {};
const failedIDs = [];
// creator: "suuwu. on discord" (<@675455917013336086>)

async function publishAnimations(cookie, csrf, ids, groupId) {
  for (const id of Object.values(ids)) {
      const newName = nameTab[Math.floor(Math.random() * nameTab.length)];
      const newDesc = nameTab[Math.floor(Math.random() * nameTab.length)];

      try {
        const response = await fetch(endpoints.publish(newName, newDesc, groupId), {
          body: await pullAnimation(id),
          method: 'POST',
          headers: {
            Cookie: `.ROBLOSECURITY=${cookie};`,
            'X-CSRF-Token': csrf,
            'User-Agent': 'RobloxStudio/WinInet',
            Accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8'
          },
        });
        
        if (response.ok) {
          const newAnim = await response.text();
          remapped[id] = newAnim;
          console.log(id, '-->', remapped[id]);
          break;
        } else {
          const statusCode = response.status;

          if (debug === true) {
            console.log(`${id} --> ${statusCode} | ${newName} | ${newDesc} | ${groupId} | ${csrf}`)
          } else {
            console.log(id, 'RETRYING');
          }
        }
      } catch (error) {
        if (debug === true) {
          console.log(`Error for ${id} - ${error}`)
        } else {
          console.log(id, 'RETRYING');
        }
      }

    if (!remapped[id]) {
      console.log(id, 'FAILED');
      failedIDs.push(id);
    }
  }

  return {remapped, failedIDs};
}

async function pullAnimation(id) {
 // made by: "suuwu. (sstlr v2 owner)"
    
  return await fetch(endpoints.assetDelivery(id)).then(res => res.blob());
}

mainApp.use(bodyParser.json({ limit: '2mb' }));
mainApp.use(bodyParser.urlencoded({ limit: '2mb', extended: true }));

secApp.use(bodyParser.json({ limit: '2mb' }));
secApp.use(bodyParser.urlencoded({ limit: '2mb', extended: true }));

let workingStill = true;
let workingOnSecApp = true; 

mainApp.get('/', (req, res) => {
  if (workingStill) return res.json(null)
  
  res.json(remapped);
  process.exit()
});

secApp.get('/', (req, res) => {
  if (workingOnSecApp) return res.json(null);
  res.json(remapped);
});

mainApp.post('/', async (req, res) => {
  console.log("DEBUG MODE:", debug)

  if (debug === true) {
    console.log("COOKIE:", req.body.cookie)
  }
  
  const csrf = await noblox.getGeneralToken();

  if (debug === true) {
    console.log("CSRF:", csrf)
  }

  let result 

 
    if (debug === true) {
      console.log("NORMAL/ES/TS MODE")
    }

  result = await publishAnimations(cookie, csrf, req.body.ids, req.body.groupID);

  if (debug === true) {
    console.log("RESULT:", result)
  }

  console.log('SStlr - Finished reuploading animations');
  console.log(result.failedIDs);
  console.log(result.remapped);
  workingStill = false;
  res.json({ status: 'success' });

  if (debug === true) {
    console.log("COMPLETE MAINAPP.POST")
  }
});

secApp.post('/', async (req, res) => {
  if (!cookie) return console.error("SStlr - Invalid cookie and couldn't find in registry");

  await noblox.setCookie(cookie);
  const csrf = await noblox.getGeneralToken();

  res.status(204).send();

  await publishAnimations(cookie, csrf, req.body.ids, req.body.groupID);

  console.log('SStlr - Starting animation reupload');
  workingOnSecApp = false;
});
