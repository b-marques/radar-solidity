pragma solidity ^0.4.24;

/*
 *  @file radar.sol
 *
 *  @brief Arquivo que possui implementação de sistema de radares com Smart contract.
 *
 *  Arquivo que simula o registro de radares, registro de infrações e seu
 *  passo a passo no sistema de controle de autuações e multas, fazendo uso de 
 *  smart contracts
 *
 *  @author Bruno Marques do Nascimento 
 *  @authro Johann Westphall
 *  @date 21/06/2018 
 *  @version 1.0
 */


/*
 *  Smart contract responsável pelo registro de um radar e suas infrações.
 */
contract RegistraInfracao {
/*
 *  Struct que representa um infração.
 */
    struct Infracao {
        string local;
        string descricao;
        uint256 timestamp;
    }
    Infracao infracao;
    SistemaControle sistema; /* Referencia para o sistema de controle de multas */
    address owner = msg.sender;
    
    constructor(address system) public {
        sistema = SistemaControle(system);
    }

/*
 *  Modificador que permite que apenas a wallet dona do radar possa executar.
 */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

/*
 *  Função que gera uma infração detectada pelo radar, o modificador onlyOwner faz
 *  com que apenas a wallet atrelada ao radar possa de fato gerar a infração.
 */
    function novaInfracao(string _local, string _descricao) public onlyOwner {
        infracao.local = _local;
        infracao.descricao = _descricao;
        infracao.timestamp = now;
    }

/*
 *  Função que "chama" uma função do sistema de multas para transformar a infração
 *  obtida em autuação no sistema.
 */ 
    function enviaInfracao() public onlyOwner {
        sistema.infracaoParaAutuacao(infracao.local, infracao.descricao, infracao.timestamp);
    }
}

/*
 *  Smart contract responsável pelo pela representação e funcionamento do sistema
 *  de gerenciamento de multas.
 */
contract SistemaControle {
/*
 *  Struct que representa um radar.
 */
    struct Radar {
        address owner;
        string endereco;
        bool permissao;
    }
/*
 *  Struct que representa uma autuação.
 */
    struct Autuacao {
        string local;
        string descricao;
        uint256 timestamp;
        address emissor;
        bool anulada;
    }
/*
 *  Struct que representa uma multa.
 */
    struct Multa {
        string local;
        string descricao;
        uint256 timestamp;
        address emissor;
        bool notificada;
        uint256 data_notificacao;
        bool ativa;
    }
/*
 *  Mapeamento para registrar os radares com permissão de emissão de autuação.
 */
    mapping(address=>Radar) radar_registrado;

    Autuacao autuacao;
    Multa multa;
    Autuacao[] autuacoes; /* Lista de autuações no sistema. */
    Multa[] multas;       /* Lista de multas no sistema.    */
    address proprietario_sistema; /* Wallet dona do sistema */
    
    constructor() public {
        proprietario_sistema = msg.sender;
    }

/*
 *  Modificador que permite que apenas a wallet dona do sistema possa executar.
 */
    modifier onlyOwner() {
        require(msg.sender == proprietario_sistema);
        _;
    }

/*
 *  Modificador que permite que apenas radares registrados executem determinado código.
 */
    modifier onlyRegisteredRadar(address _sender) {
        require(radar_registrado[_sender].permissao);
        _;
    }

/*
 *  Função que simula a verificação de alguma avaria ou inconformidade na infração registrada.
 */
    function infracaoComAvaria() public view returns(bool){
        uint random_number = uint(blockhash(block.number-1))%10 + 1;
        return(random_number == 5);
    }

/*
 *  Função responsável por registrar um radar no sistema, apenas a wallet proprietária pode registrar um radar.
 */
    function registraRadar(address owner_radar, string endereco) onlyOwner public {
        radar_registrado[owner_radar].owner = owner_radar;
        radar_registrado[owner_radar].endereco = endereco;
        radar_registrado[owner_radar].permissao = true;
    }

/*
 *  Função responsável por guardar no sistema a infração registrada pelo radar, apenas radares registrados no 
 *  sistema podem executá-la.
 */
    function infracaoParaAutuacao(string _local, string _descricao, uint256 _timestamp) public onlyRegisteredRadar(msg.sender) {
        autuacao.local = _local;
        autuacao.descricao = _descricao;
        autuacao.timestamp = _timestamp;
        autuacao.emissor = msg.sender;
        autuacao.anulada = false;
        if(infracaoComAvaria()){ // Verifica avarias na infracao
            autuacao.anulada = true;
        }
        autuacoes.push(autuacao);
    }

/*
 *  Função responsável por emitir as notificações para todas as autuações registradas no sistema, verifica
 *  se o prazo de 30 dias para emissão da notificação foi extrapolado ou se a autuação foi anulada.
 */
    function emitirNotificacoes() public onlyOwner{
        for(uint256 i = 0; i < autuacoes.length; i++){
           if(now - autuacoes[i].timestamp < uint256(2592000)) { /* 2592000 = 30 dias em timestamp        */
                if(!autuacoes[i].anulada){ /* Verifica se a autucao não foi anulada por causa de avarias. */
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
        autuacoes.length = 0; /* Limpa a lista de autuações */
    }

/*
 *  Função responsável por transformar uma autuação que foi notificada para uma multa, que ocorre após o 
 *  prazo de 30 dias da notificação do infrator.
 */
    function notificacaoParaMulta() public onlyOwner{
        for(uint256 i = 0; i < multas.length; i++){
           /* Verifica se já se passaram 30 dias após notificação. */
           if(now - multas[i].data_notificacao > uint256(2592000)) { /* 2592000 = 30 dias em timestamp */
                if(!multas[i].ativa) {
                    multas[i].ativa = true;
                }
           }
        }
    }
}