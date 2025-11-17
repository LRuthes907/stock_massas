class Produto {
  final int? id;
  final String? remoteId;
  final String nome;
  final double preco;
  final int quantidade;
  final DateTime? dataValidade;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;
  final bool dirty;
  final bool deleted;

  Produto({
    this.id,
    this.remoteId,
    required this.nome,
    required this.preco,
    required this.quantidade,
    this.dataValidade,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    this.dirty = true,
    this.deleted = false,
  }) : dataCriacao = dataCriacao ?? DateTime.now(),
       dataAtualizacao = dataAtualizacao ?? DateTime.now();

  Produto copyWith({
    int? id,
    String? remoteId,
    String? nome,
    double? preco,
    int? quantidade,
    DateTime? dataValidade,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    bool? dirty,
    bool? deleted,
  }) {
    final bool isDataChange =
        nome != null ||
        preco != null ||
        quantidade != null ||
        dataValidade != null;

    return Produto(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      quantidade: quantidade ?? this.quantidade,
      dataValidade: dataValidade ?? this.dataValidade,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao:
          dataAtualizacao ??
          (isDataChange ? DateTime.now() : this.dataAtualizacao),
      dirty: dirty ?? (isDataChange ? true : this.dirty),
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remoteId': remoteId,
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
      'dataValidade': dataValidade?.millisecondsSinceEpoch,
      'dataCriacao': dataCriacao.millisecondsSinceEpoch,
      'dataAtualizacao': dataAtualizacao.millisecondsSinceEpoch,
      'dirty': dirty ? 1 : 0,
      'deleted': deleted ? 1 : 0,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    final validadeMillis = map['dataValidade'] as int?;
    final DateTime? dataValidade = validadeMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(validadeMillis)
        : null;

    DateTime parseMillis(dynamic v, [DateTime? fallback]) {
      if (v == null) return fallback ?? DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String)
        return DateTime.tryParse(v) ?? fallback ?? DateTime.now();
      return fallback ?? DateTime.now();
    }

    return Produto(
      id: map['id'] as int?,
      remoteId: map['remoteId'] as String?,
      nome: map['nome'] as String,
      preco: (map['preco'] as num).toDouble(),
      quantidade: (map['quantidade'] as num).toInt(),
      dataValidade: dataValidade,
      dataCriacao: parseMillis(map['dataCriacao']),
      dataAtualizacao: parseMillis(map['dataAtualizacao']),
      dirty: (map['dirty'] ?? 0) == 1,
      deleted: (map['deleted'] ?? 0) == 1,
    );
  }

  // Firestore-safe Map (no direct Timestamp dependency)
  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
      'dataValidade': dataValidade?.toIso8601String(),
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataAtualizacao': dataAtualizacao.toIso8601String(),
      'deleted': deleted,
    };
  }

  // Accepts Timestamp-like (has toDate()), int millis or ISO string
  factory Produto.fromFirestore(Map<String, dynamic> map, {String? id}) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        // Firebase Timestamp
        final toDate = v.toDate;
        if (toDate is Function) return toDate();
      } catch (_) {}
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    final dataValidade = parseDate(map['dataValidade']);
    final dataCriacao = parseDate(map['dataCriacao']) ?? DateTime.now();
    final dataAtualizacao = parseDate(map['dataAtualizacao']) ?? DateTime.now();

    return Produto(
      id: null,
      remoteId: id,
      nome: map['nome'] as String,
      preco: (map['preco'] as num).toDouble(),
      quantidade: (map['quantidade'] as num).toInt(),
      dataValidade: dataValidade,
      dataCriacao: dataCriacao,
      dataAtualizacao: dataAtualizacao,
      dirty: false,
      deleted: (map['deleted'] ?? false) as bool,
    );
  }
}
