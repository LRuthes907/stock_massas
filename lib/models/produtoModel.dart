Class produto {

final int? id; // ID do banco de dados local (auto-increment)
final String? remoteId
final String nome;
final double precoVenda;
final int quantidade;
final DataTime? dataValidade
final DateTime dataCriacao;
final DateTime dataAtualizacao;
final bool dirty;
final bool deleted;


produto({
this.id,
this.remoteId
required this.nome,
required.this precoVenda
required this.quantidade
this.dataValidade
DateTime? dataCriacao
DateTime? dataAtualizacao,
this.disty = true,
this.delete = false
}) : 

    this.dataCriacao = dataCriacao ?? DateTime.now(),
    this.dataAtualizacao = dataAtualizacao ?? DateTime.now();

produto copyWith({
   inal int? id; // ID do banco de dados local (auto-increment)
String? remoteId
String nome;
double precoVenda;
int quantidade;
DataTime? dataValidade
DateTime dataCriacao;
DateTime dataAtualizacao;
bool dirty;
bool deleted;
  }) {

    final bool isDataChange = nome != null ||
    preco != null ||
    quantidade != null ||
    dataValidade != null;

    return produto(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      quantidadeEstoque: quantidadeEstoque ?? this.quantidadeEstoque,
      dataValidade: dataValidade ?? this.dataValidade,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: (dataAtualizacao ?? (isDataChange ? DateTime.now() : this.dataAtualizacao)),
      dirty: dirty ?? (isDataChange ? true : this.dirty),
      deleted: deleted ?? this.deleted,
    );
  }


// Método para converter para Map (para salvar no sqflite)
Map<String, dynamic> toMap() {
return {
'id': id,
'remoteId': remoteId
'nome': nome,
'preco': preco
'quantidade': quantidade,
'datavalidade' dataValidade?.millisecondsSinceEpoch,
'dataCriacao': dataCriacao.millisecondsSinceEpoch,
'dataAtualizacao': dataAtualizacao.millisecondsSinceEpoch,
'dirty': dirty ? 1 : 0, // Boolean vira Inteiro (1 ou 0)
'deleted': deleted ? 1 : 0,
};
}


// Método para criar de um Map (para ler do sqflite)

factory Product.fromMap(Map<String, dynamic> map) {
    final int? validadeMillis = map['dataValidade'] as int?;
    final DateTime? dataValidade = validadeMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(validadeMillis)
        : null;
return Product(
id: map['id'] as int?,
remoteId: map['remoteId'] as String?
nome: map['nome'] as String,
preco: (map['preco']as num).toDouble(),
quantidade: (map['quantidade']as num).toInt(),
dataValidade: dataValidade
dataCriacao: DateTime.fromMillisecondsSinceEpoch(map['dataCriacao'] as int),
dataAtualizacao: DateTime.fromMillisecondsSinceEpoch(map['dataAtualizacao'] as int),
dirty: (map['dirty'] as int) == 1,
 deleted: (map['deleted'] as int) == 1,
);
}

map<String, dynamic> toFirestore(){
    'nome': nome,
    'preco': preco
    'qunatidade': quantidade
    'dataValidade': dataValidade != null ? Timestamp.fromDate(dataValidade!) : null,
    'dataCriacao': Timestamp.fromDate(dataCriacao),
    'dataAtualizacao': Timestamp.fromDate(dataAtualizacao),
    'deleted': deleted,
}

factory produto.fromFirestore(
    Map<String, dynamic> map, {
        String? id,
    }){
        final Timestamp? validadeTs = map['dateValidade'] as  Timestamp?;
        final DateTime? dataValidade = validadeTs?.toDate();

        return produto(
            remoteId: id,
            nome: map['nome'] as String,
            preco: (map['preco']as num).toDouble(),
            quantidadeEstoque: (map['quantidade']as num).toInt(),
            dataValidade: dataValidade,
            dataCriacao: (map['dataCriacao'] as Timestamp).toDate(),
            dataAtualizacao: (map['dataAtualizacao'] as Timestamp).toDate(),
            dirty: false,
            deleted: (map['deleted'] ?? false) as bool,
        )
    }
    
    }

