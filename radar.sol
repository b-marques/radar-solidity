pragma solidity ^0.4.11;

// wei to ether: 1000000000000000000

contract RegistraInfracao {
    struct Infracao {
        string local;
        string descricao;
        uint256 timestamp;
        address emissor;
    }
    Infracao infracao;
    
    constructor(string _local, string _descricao, address system) public payable {
        infracao.emissor = msg.sender;
        infracao.local = _local;
        infracao.descricao = _descricao;
        infracao.timestamp = now;
        
        SistemaControle sistema = SistemaControle(system);
        sistema.infracaoParaAutuacao(infracao.local, infracao.descricao, infracao.timestamp);
    }
}

contract SistemaControle {
    struct Radar {
        address owner;
        string endereco;
        bool permissao;
    }
    struct Infracao {
        string local;
        string descricao;
        uint256 timestamp;
        address emissor;
        bool anulada;
    }
    struct Multa {
        string local;
        string descricao;
        uint256 timestamp;
        address emissor;
        bool notificada;
        uint256 data_notificacao;
        bool ativa;
    }
    mapping(address=>Radar) radar_registrado;
    Infracao[] autuacoes;
    Multa[] multas;
    uint n_autuacoes = 0;
    uint n_multas = 0;
    address proprietario_sistema = msg.sender;
    
    constructor() public payable {
        proprietario_sistema = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == proprietario_sistema);
        _;
    }
    
    modifier onlyRegisteredRadar() {
        require(radar_registrado[msg.sender].permissao);
        _;
    }
    
    function multaComAvaria() public view returns(bool){
        uint random_number = uint(blockhash(block.number-1))%10 + 1;
        return(random_number == 5);
    }
    
    function registraRadar(address owner_radar, string endereco) onlyOwner public {
        radar_registrado[owner_radar].owner = owner_radar;
        radar_registrado[owner_radar].endereco = endereco;
        radar_registrado[owner_radar].permissao = true;
    }
    
    function infracaoParaAutuacao(string local, string descricao, uint256 timestamp) public onlyRegisteredRadar payable {
        autuacoes[n_autuacoes].local = local;
        autuacoes[n_autuacoes].descricao = descricao;
        autuacoes[n_autuacoes].timestamp = timestamp;
        autuacoes[n_autuacoes].emissor = msg.sender;
        autuacoes[n_autuacoes].anulada = false;
        if(multaComAvaria()){ // Verifica avarias na infracao
            autuacoes[n_autuacoes].anulada = true;
        }
        n_autuacoes = n_autuacoes + 1;
    }
    
    function emitirNotificacoes() public onlyOwner{
        for(uint256 i = 0; i < autuacoes.length; i++){
           if(now - autuacoes[i].timestamp < uint256(2592000)) { // 2592000 = 30 dias em timestamp
                if(!autuacoes[i].anulada){ // Verifica se a autucao não foi anulada por causa de avarias.
                    multas[n_multas].local = autuacoes[i].local;
                    multas[n_multas].descricao = autuacoes[i].descricao;
                    multas[n_multas].timestamp = autuacoes[i].timestamp;
                    multas[n_multas].emissor = autuacoes[i].emissor;
                    multas[n_multas].notificada = true;
                    multas[n_multas].data_notificacao = now;
                    multas[n_multas].ativa = false;
                    n_multas = n_multas + 1;
                }
           }
        }
        n_autuacoes = 0;
    }
    
    function notificacaoParaMulta() public onlyOwner{
        for(uint256 i = 0; i < multas.length; i++){
           if(now - multas[i].data_notificacao > uint256(2592000)) { // 2592000 = 30 dias em timestamp
                if(!multas[i].ativa) {
                    multas[i].ativa = true;
                }
           }
        }
    }
}