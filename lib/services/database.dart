import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'registro_mergulho.db');
    return await openDatabase(
      path,
      version: 4, // versão nova
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Operacao (
        id TEXT PRIMARY KEY,
        data TEXT,
        local TEXT,
        descricao TEXT,
        altitude INTEGER,
        pressaoAmbiente REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE Mergulhador (
        id TEXT PRIMARY KEY,
        nome TEXT,
        matricula TEXT,
        graduacao TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Mergulho (
        id TEXT PRIMARY KEY,
        operacao_id TEXT NOT NULL,
        mergulhador_id TEXT NOT NULL,
        profundidade_max INTEGER,
        tempo_fundo INTEGER,
        tempo_total INTEGER,
        temperatura_agua REAL,
        visibilidade INTEGER,
        tipo_gas TEXT,
        pressao_inicial INTEGER,
        pressao_final INTEGER,
        volume_cilindro INTEGER,
        tipo_roupa TEXT,
        lastro_usado INTEGER,
        correnteza TEXT,
        condicoes_mar TEXT,
        observacoes TEXT,
        altitude_efetiva INTEGER,
        horario_descida TEXT,
        horario_subida TEXT,
        latitude REAL,
        longitude REAL,
        altitude INTEGER,
        FOREIGN KEY (operacao_id) REFERENCES Operacao(id),
        FOREIGN KEY (mergulhador_id) REFERENCES Mergulhador(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // migrações da tabela Mergulhador
      await db.execute('ALTER TABLE Mergulhador ADD COLUMN matricula TEXT');

      // migrações da tabela Mergulho
      await db.execute('ALTER TABLE Mergulho ADD COLUMN horario_descida TEXT');
      await db.execute('ALTER TABLE Mergulho ADD COLUMN horario_subida TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE Mergulho ADD COLUMN latitude REAL');
      await db.execute('ALTER TABLE Mergulho ADD COLUMN longitude REAL');
      await db.execute('ALTER TABLE Mergulho ADD COLUMN altitude INTEGER');
    }

  }
}
