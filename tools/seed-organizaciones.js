require('dotenv').config();
const {
  Client, Databases, Permission, Role, ID, Query,
} = require('node-appwrite');

const client = new Client()
  .setEndpoint(process.env.APPWRITE_ENDPOINT)
  .setProject(process.env.APPWRITE_PROJECT_ID)
  .setKey(process.env.APPWRITE_API_KEY);

const db = new Databases(client);
const DB_ID = 'electoral_db';
const COL_ORG = 'organizaciones';

const ALCALDES = [
  { nombre: 'Alianza PAIS',           siglas: 'AP',  candidatoNombres: 'Juan Carlos',  candidatoApellidos: 'Pérez Mendoza',  numeroLista: 1, colorHex: '#FFB300' },
  { nombre: 'Movimiento CREO',        siglas: 'CREO',candidatoNombres: 'María Fernanda', candidatoApellidos: 'Ortega Vega',  numeroLista: 2, colorHex: '#1565C0' },
  { nombre: 'PSC - Madera de Guerrero',siglas: 'PSC', candidatoNombres: 'Luis Eduardo',  candidatoApellidos: 'Ramírez López', numeroLista: 3, colorHex: '#2E7D32' },
  { nombre: 'Revolución Ciudadana',    siglas: 'RC',  candidatoNombres: 'Ana Lucía',     candidatoApellidos: 'Sánchez Torres',numeroLista: 4, colorHex: '#D32F2F' },
  { nombre: 'SUMA',                   siglas: 'SUMA',candidatoNombres: 'Pedro Pablo',   candidatoApellidos: 'Cevallos Ruiz',numeroLista: 5, colorHex: '#7B1FA2' },
];

const PREFECTOS = [
  { nombre: 'Alianza PAIS',            siglas: 'AP',   candidatoNombres: 'Roberto Carlos', candidatoApellidos: 'Maldonado Pico',  numeroLista: 1, colorHex: '#FFB300' },
  { nombre: 'Movimiento CREO',         siglas: 'CREO', candidatoNombres: 'Sofía Beatriz',  candidatoApellidos: 'Vera Solórzano',  numeroLista: 2, colorHex: '#1565C0' },
  { nombre: 'PSC - Madera de Guerrero',siglas: 'PSC',  candidatoNombres: 'Diego Armando',  candidatoApellidos: 'Zambrano Intriago',numeroLista: 3, colorHex: '#2E7D32' },
  { nombre: 'Revolución Ciudadana',    siglas: 'RC',   candidatoNombres: 'Patricia Elena', candidatoApellidos: 'Cordero Baquero', numeroLista: 4, colorHex: '#D32F2F' },
  { nombre: 'SUMA',                    siglas: 'SUMA', candidatoNombres: 'Manuel Ignacio',  candidatoApellidos: 'Yépez Calderón',  numeroLista: 5, colorHex: '#7B1FA2' },
];

async function exists(dignidad, lista) {
  try {
    const res = await db.listDocuments(DB_ID, COL_ORG, [
      Query.equal('dignidad', dignidad),
      Query.equal('numeroLista', lista),
    ]);
    return res.documents.length > 0;
  } catch {
    return false;
  }
}

async function seed() {
  console.log('🌱 Sembrando organizaciones políticas...');

  for (const a of ALCALDES) {
    if (await exists('Alcalde', a.numeroLista)) {
      console.log(`   ✔ Alcalde lista ${a.numeroLista} (${a.siglas}) ya existe`);
      continue;
    }
    await db.createDocument(DB_ID, COL_ORG, ID.unique(), {
      dignidad: 'Alcalde',
      ...a,
    });
    console.log(`   ✔ Alcalde lista ${a.numeroLista}: ${a.siglas} - ${a.candidatoNombres} ${a.candidatoApellidos}`);
  }

  for (const p of PREFECTOS) {
    if (await exists('Prefecto', p.numeroLista)) {
      console.log(`   ✔ Prefecto lista ${p.numeroLista} (${p.siglas}) ya existe`);
      continue;
    }
    await db.createDocument(DB_ID, COL_ORG, ID.unique(), {
      dignidad: 'Prefecto',
      ...p,
    });
    console.log(`   ✔ Prefecto lista ${p.numeroLista}: ${p.siglas} - ${p.candidatoNombres} ${p.candidatoApellidos}`);
  }

  console.log('\n✅ Organizaciones precargadas.');
}

seed().catch((e) => { console.error('❌ Error:', e); process.exit(1); });
