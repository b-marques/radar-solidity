pragma solidity ^0.4.24;

// wei to ether: 1000000000000000000

contract RegistraInfracao {
    struct Infracao {
        string local;
        string descricao;
        uint256 timestamp;
    }
    Infracao infracao;
    SistemaControle sistema;
    
    constructor(address system) public {
        sistema = SistemaControle(system);
    }
    
    function novaInfracao(string _local, string _descricao) public {
        infracao.local = _local;
        infracao.descricao = _descricao;
        infracao.timestamp = now;
    }
    
    function enviaInfracao() public {
        sistema.infracaoParaAutuacao(infracao.local, infracao.descricao, infracao.timestamp);
    }
}

contract SistemaControle {
    struct Radar {
        address owner;
        string endereco;
        bool permissao;
    }
    struct Autuacao {
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
    Autuacao autuacao;
    Multa multa;
    Autuacao[] autuacoes;
    Multa[] multas;
    address proprietario_sistema = msg.sender;
    
    constructor() public {
        proprietario_sistema = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == proprietario_sistema);
        _;
    }
    
    modifier onlyRegisteredRadar(address _sender) {
        require(radar_registrado[_sender].permissao);
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
    
    function infracaoParaAutuacao(string _local, string _descricao, uint256 _timestamp) public onlyRegisteredRadar(msg.sender) {
        autuacao.local = _local;
        autuacao.descricao = _descricao;
        autuacao.timestamp = _timestamp;
        autuacao.emissor = msg.sender;
        autuacao.anulada = false;
        if(multaComAvaria()){ // Verifica avarias na infracao
            autuacao.anulada = true;
        }
        autuacoes.push(autuacao);
    }
    
    function emitirNotificacoes() public onlyOwner{
        for(uint256 i = 0; i < autuacoes.length; i++){
           if(now - autuacoes[i].timestamp < uint256(2592000)) { // 2592000 = 30 dias em timestamp
                if(!autuacoes[i].anulada){ // Verifica se a autucao não foi anulada por causa de avarias.
                    multa.local = autuacoes[i].local;
                    multa.descricao = autuacoes[i].descricao;
                    multa.timestamp = autuacoes[i].timestamp;
                    multa.emissor = autuacoes[i].emissor;
                    multa.notificada = true;
                    multa.data_notificacao = now;
                    multa.ativa = false;
                    multas.push(multa);
                }
           }
        }
        autuacoes.length = 0;
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