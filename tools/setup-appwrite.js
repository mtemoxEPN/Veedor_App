require('dotenv').config();
const {
  Client, Databases, Teams, Storage,
  Permission, Role, ID, IndexType, AttributeType,
} = require('node-appwrite');

const client = new Client()
  .setEndpoint(process.env.APPWRITE_ENDPOINT)
  .setProject(process.env.APPWRITE_PROJECT_ID)
  .setKey(process.env.APPWRITE_API_KEY);

const db       = new Databases(client);
const teamsApi = new Teams(client);
const storage  = new Storage(client);

const DB_ID = 'electoral_db';

const COL = {
  perfiles:        'perfiles',
  recintos:        'recintos',
  mesas:           'mesas',
  asignaciones:    'asignaciones',
  actas:           'actas',
  organizaciones:  'organizaciones',
};

const TEAM = {
  provinciales:           'coordinadores-provinciales',
  coordinadoresRecinto:   'coordinadores-recinto',
  veedores:               'veedores',
};

const BUCKET = { actas: 'actas-fotos' };

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function existsTeam(id) {
  try { await teamsApi.get(id); return true; }
  catch { return false; }
}
async function existsCollection(colId) {
  try { await db.getCollection(DB_ID, colId); return true; }
  catch { return false; }
}
async function existsBucket(id) {
  try { await storage.getBucket(id); return true; }
  catch { return false; }
}

async function main() {
  console.log('🗄️  Creando database...');
  try { await db.create(DB_ID, 'Elecciones Ecuador 2026'); }
  catch (e) { console.log('   (ya existe, ok)'); }

  // TEAMS
  console.log('👥 Creando teams...');
  const teamDefs = [
    { id: TEAM.provinciales,        name: 'Coordinadores Provinciales' },
    { id: TEAM.coordinadoresRecinto,name: 'Coordinadores de Recinto' },
    { id: TEAM.veedores,            name: 'Veedores de Mesa' },
  ];
  for (const t of teamDefs) {
    if (await existsTeam(t.id)) { console.log(`   ✔ team ${t.id} ya existe`); continue; }
    await teamsApi.create(t.id, t.name);
    console.log(`   ✔ team ${t.id} creado`);
  }

  // COLECCIÓN: PERFILES
  console.log('📄 Colección: perfiles');
  if (!(await existsCollection(COL.perfiles))) {
    await db.createCollection(
      DB_ID, COL.perfiles, 'Perfiles de Usuario',
      [
        Permission.create(Role.team(TEAM.provinciales)),
        Permission.create(Role.team(TEAM.coordinadoresRecinto)),
        Permission.read(Role.users()),
        Permission.update(Role.team(TEAM.provinciales)),
        Permission.update(Role.team(TEAM.coordinadoresRecinto)),
        Permission.delete(Role.team(TEAM.provinciales)),
      ],
    );
    await sleep(500);
    await db.createAttribute(DB_ID, COL.perfiles, 'userId',       255, true,  AttributeType.String);
    await db.createAttribute(DB_ID, COL.perfiles, 'cedula',       10,  true,  AttributeType.String);
    await db.createAttribute(DB_ID, COL.perfiles, 'nombres',      255, true,  AttributeType.String);
    await db.createAttribute(DB_ID, COL.perfiles, 'apellidos',    255, true,  AttributeType.String);
    await db.createAttribute(DB_ID, COL.perfiles, 'telefono',     10,  true,  AttributeType.String);
    await db.createAttribute(DB_ID, COL.perfiles, 'email',        255, true,  AttributeType.Email);
    await db.createAttribute(DB_ID, COL.perfiles, 'rol',          20,  true,  AttributeType.String); 
    await db.createAttribute(DB_ID, COL.perfiles, 'recintoId',    255, false, AttributeType.String, undefined, true);
    await db.createAttribute(DB_ID, COL.perfiles, 'primerLogin',  1,   true,  AttributeType.Boolean);
  }

  // COLECCIÓN: RECINTOS
  console.log('📄 Colección: recintos');
  if (!(await existsCollection(COL.recintos))) {
    await db.createCollection(
      DB_ID, COL.recintos, 'Recintos Electorales',
      [
        Permission.create(Role.team(TEAM.provinciales)),
        Permission.read(Role.users()),
        Permission.update(Role.team(TEAM.provinciales)),
        Permission.delete(Role.team(TEAM.provinciales)),
      ],
    );
    await sleep(500);
    await db.createAttribute(DB_ID, COL.recintos, 'canton',     100, true, AttributeType.String);
    await db.createAttribute(DB_ID, COL.recintos, 'parroquia',  100, true, AttributeType.String);
    await db.createAttribute(DB_ID, COL.recintos, 'nombre',     255, true, AttributeType.String);
    await db.createAttribute(DB_ID, COL.recintos, 'provincia',  100, true, AttributeType.String);
    await db.createAttribute(DB_ID, COL.recintos, 'totalJrvs',  1,   true, AttributeType.Integer);
    await db.createAttribute(DB_ID, COL.recintos, 'createdBy',  255, true, AttributeType.String);
  }

  // COLECCIÓN: MESAS
  console.log('📄 Colección: mesas');
  if (!(await existsCollection(COL.mesas))) {
    await db.createCollection(
      DB_ID, COL.mesas, 'Mesas / JRV',
      [
        Permission.create(Role.team(TEAM.provinciales)),
        Permission.create(Role.team(TEAM.coordinadoresRecinto)),
        Permission.read(Role.users()),
        Permission.update(Role.team(TEAM.coordinadoresRecinto)),
        Permission.delete(Role.team(TEAM.provinciales)),
      ],
    );
    await sleep(500);
    await db.createAttribute(DB_ID, COL.mesas, 'recintoId',  255, true,  AttributeType.String);
    await db.createAttribute(DB_ID, COL.mesas, 'numeroJr',   10,  true,  AttributeType.String);
    await db.createAttribute(DB_ID, COL.mesas, 'estado',     20,  true,  AttributeType.String);
  }

  // COLECCIÓN: ACTAS
  console.log('📄 Colección: actas');
  if (!(await existsCollection(COL.actas))) {
    await db.createCollection(
      DB_ID, COL.actas, 'Actas de Escrutinio',
      [
        Permission.create(Role.team(TEAM.veedores)),
        Permission.read(Role.users()),   
        Permission.update(Role.team(TEAM.coordinadoresRecinto)),
        Permission.update(Role.team(TEAM.veedores)),
      ],
    );
    await sleep(500);
    await db.createAttribute(DB_ID, COL.actas, 'mesaId',            255, true,  AttributeType.String);
    await db.createAttribute(DB_ID, COL.actas, 'tipoActa',          20,  true,  AttributeType.String); 
    await db.createAttribute(DB_ID, COL.actas, 'votosCandidato1',   1,   true,  AttributeType.Integer);
    await db.createAttribute(DB_ID, COL.actas, 'votosCandidato2',   1,   true,  AttributeType.Integer);
    await db.createAttribute(DB_ID, COL.actas, 'votosCandidato3',   1,   true,  AttributeType.Integer);
    await db.createAttribute(DB_ID, COL.actas, 'votosCandidato4',   1,   true,  AttributeType.Integer);
    await db.createAttribute(DB_ID, COL.actas, 'votosCandidato5',   1,   true,  AttributeType.Integer);
    await db.createAttribute(DB_ID, COL.actas, 'votosBlancos',      1,   true,  AttributeType.Integer);
    await db.createAttribute(DB_ID, COL.actas, 'votosNulos',        1,   true,  AttributeType.Integer);
    await db.createAttribute(DB_ID, COL.actas, 'totalSufragantes',  1,   true,  AttributeType.Integer);
    await db.createAttribute(DB_ID, COL.actas, 'fotoUrl',           500, true,  AttributeType.String);
    await db.createAttribute(DB_ID, COL.actas, 'latitud',           20,  true,  AttributeType.Float);
    await db.createAttribute(DB_ID, COL.actas, 'longitud',          20,  true,  AttributeType.Float);
    await db.createAttribute(DB_ID, COL.actas, 'novedades',         500, false, AttributeType.String);
  }

  // BUCKET: ACTAS-FOTOS
  console.log('🪣 Bucket: actas-fotos');
  if (!(await existsBucket(BUCKET.actas))) {
    await storage.createBucket(
      BUCKET.actas, 'Fotos de Actas',
      [
        Permission.create(Role.team(TEAM.veedores)),
        Permission.create(Role.team(TEAM.coordinadoresRecinto)),
        Permission.read(Role.users()),
        Permission.update(Role.team(TEAM.veedores)),
        Permission.update(Role.team(TEAM.coordinadoresRecinto)),
        Permission.delete(Role.team(TEAM.coordinadoresRecinto)),
      ],
      false,                  
      undefined, undefined,   
    );
  }

  console.log('\n✅ Configuración de Appwrite completada.');
}

main().catch((e) => { console.error('❌ Error:', e); process.exit(1); });
