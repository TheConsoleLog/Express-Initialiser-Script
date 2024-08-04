clear
read -p "What's your name, master? (default=backend): " base_name

if [[ -z $base_name ]]; then
  base_name=backend
fi

echo "🤘 $base_name will be created..."

if [[ -d $base_name ]]; then
  read -p "❓ Folder already exists... Do you want to delete it? (y) " delete_folder
  if [[ $delete_folder == "y" ]]; then
    rm -r $base_name
  else
    exit 0
  fi
fi

mkdir $base_name
cd $base_name

npm init -y
npm i express cors dotenv zod express-async-errors
npm install --save-dev @types/express @types/cors @types/node ts-node ts-node-dev typescript cross-env

touch .gitignore
touch .env
touch tsconfig.json

echo "lib-cov
*.seed
*.log
*.csv
*.dat
*.out
*.pid
*.gz
*.swp

pids
logs
results
tmp

# Build
public/css/main.css

# Coverage reports
coverage

# API keys and secrets
.env

# Dependency directory
node_modules
bower_components

# Editors
.idea
*.iml
.vscode

# OS metadata
.DS_Store
Thumbs.db

# Ignore built ts files
dist/**/*

# ignore .lock
yarn.lock
package.lock" >> .gitignore

echo "PORT=3000" >> .env

echo "{
  \"compilerOptions\": {
    \"target\": \"es2016\",                                  /* Set the JavaScript language version for emitted JavaScript and include compatible library declarations. */
    \"module\": \"commonjs\",                                /* Specify what module code is generated. */
    \"outDir\": \"./dist\",                                   /* Specify an output folder for all emitted files. */
    \"esModuleInterop\": true,                             /* Emit additional JavaScript to ease support for importing CommonJS modules. This enables 'allowSyntheticDefaultImports' for type compatibility. */
    \"forceConsistentCasingInFileNames\": true,            /* Ensure that casing is correct in imports. */
    \"strict\": true,                                      /* Enable all strict type-checking options. */
    \"skipLibCheck\": true                                 /* Skip type checking all .d.ts files. */
  }
}" >> tsconfig.json

mkdir src/
cd src/

touch index.ts
src_folders=('routes' 'controllers' 'utils' 'services' 'models' 'types' 'schema' 'middleware' 'validators')

for value in "${src_folders[@]}"
do
  mkdir $value
done

echo "import express from \"express\";
import cors from \"cors\";
import routes from \"./routes\";

export const app = express();

app.listen(3000, () => console.log(`Server started!`));
app.use(cors());
app.use(express.json());
app.use(express.urlencoded());
app.use(routes);" >> index.ts

cd routes/
touch index.ts

echo "import { Router } from \"express\";

const router = Router();
export default router;" >> index.ts

cd ..
cd utils/
touch config.ts

echo "import { object, coerce } from \"zod\";
import { config } from \"dotenv\";
config();

export const envSchema = object({
  PORT: coerce.number({
    message: \"Port must be a number!\"
  }).min(0).max(65536)
});

export default envSchema.parse(process.env);" >> config.ts

read -p "⚙ Do you wanna use mongodb? (y) " mongodb
read -p "⚙ Do you wanna use any sql database? (y) " sql
read -p "⚙ Do you wanna use jwt based auth? (y) " jwt
read -p "⚙ Do you wanna use a git repo? (y) " git
read -p "⚙ Do you wanna use tests in generell? (y) " tests

if [[ $tests == "y" ]]; then
  read -p "⚙ Do you wanna use supertest? (y) " supertest
  read -p "⚙ Do you wanna use jest? (y) " jest
fi

if [[ $mongodb == "y" ]]; then
  npm install mongoose
  echo "✔ mongoose installed"
fi

if [[ $sql == "y" ]]; then
  npm install sequelize
  echo "✔ sequelize installed"
fi

if [[ $jwt == "y" ]]; then
  npm install jsonwebtoken
  echo "✔ sequelize installed"
fi

if [[ $git == "y" ]]; then
  git init
  echo "✔ git repo initialized"
fi

if [[ $tests == "y" ]]; then
  cd ../../
  mkdir tests
  cd tests

  if [[ $supertest == "y" ]]; then
    npm i --save-dev supertest
    echo "✔ supertest installed"
  fi

  if [[ $jest == "y" ]]; then
    npm i --save-dev jest
    echo "✔ jest installed"
  fi
fi

cd ../
sed -i 's/"test": "echo \\"Error: no test specified\\" && exit 1"/"test": "cross-env NODE_ENV=test node --test", "build": "tsc -p .", "dev": "cross-env NODE_ENV=dev ts-node-dev --respawn --transpile-only src\/index.ts"/' package.json

exit 0