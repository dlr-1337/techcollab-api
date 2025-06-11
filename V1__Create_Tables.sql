-- Tabela para armazenar informações dos usuários da plataforma, sejam eles profissionais ou empresas.
CREATE TABLE usuario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    tipo_usuario VARCHAR(50) NOT NULL COMMENT 'Possíveis valores: ''PROFISSIONAL'', ''EMPRESA''',
    data_cadastro DATETIME NOT NULL,
    -- Campos específicos para EMPRESA
    cnpj VARCHAR(20) UNIQUE,
    razao_social VARCHAR(255),
    descricao_empresa TEXT,
    site_url VARCHAR(255),
    -- Campos específicos para PROFISSIONAL
    portfolio_url VARCHAR(255),
    curriculo_url VARCHAR(255),
    nivel_experiencia VARCHAR(50)
);

-- Tabela para armazenar as habilidades dos profissionais.
CREATE TABLE profissional_habilidades (
    profissional_id BIGINT NOT NULL,
    habilidade VARCHAR(100) NOT NULL,
    PRIMARY KEY (profissional_id, habilidade),
    FOREIGN KEY (profissional_id) REFERENCES usuario(id) ON DELETE CASCADE
);

-- Tabela para armazenar informações sobre os projetos cadastrados pelas empresas.
CREATE TABLE projeto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descricao_detalhada TEXT NOT NULL,
    prazo_estimado VARCHAR(100),
    orcamento_estimado DECIMAL(15, 2),
    status_projeto VARCHAR(50) NOT NULL,
    data_criacao DATETIME NOT NULL,
    data_inicio_prevista DATE,
    data_conclusao_prevista DATE,
    empresa_id BIGINT NOT NULL,
    FOREIGN KEY (empresa_id) REFERENCES usuario(id) ON DELETE CASCADE
);

-- Tabela para armazenar as vagas (posições) abertas em cada projeto.
CREATE TABLE vaga_projeto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    descricao_papel VARCHAR(255) NOT NULL,
    nivel_experiencia_desejado VARCHAR(50),
    quantidade_posicoes INT DEFAULT 1 NOT NULL,
    projeto_id BIGINT NOT NULL,
    FOREIGN KEY (projeto_id) REFERENCES projeto(id) ON DELETE CASCADE
);

-- Tabela para armazenar as habilidades requeridas para cada vaga de projeto.
CREATE TABLE vaga_habilidades_requeridas (
    vaga_projeto_id BIGINT NOT NULL,
    habilidade VARCHAR(100) NOT NULL,
    PRIMARY KEY (vaga_projeto_id, habilidade),
    FOREIGN KEY (vaga_projeto_id) REFERENCES vaga_projeto(id) ON DELETE CASCADE
);

-- Tabela para registrar o interesse de profissionais em vagas de projetos.
CREATE TABLE interesse_projeto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    data_interesse DATETIME NOT NULL,
    status_interesse VARCHAR(50) NOT NULL,
    mensagem_motivacao TEXT,
    profissional_id BIGINT NOT NULL,
    vaga_projeto_id BIGINT NOT NULL,
    FOREIGN KEY (profissional_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (vaga_projeto_id) REFERENCES vaga_projeto(id) ON DELETE CASCADE
);

-- Tabela para representar as equipes formadas para cada projeto.
CREATE TABLE equipe_projeto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome_equipe VARCHAR(255),
    data_formacao DATE,
    projeto_id BIGINT NOT NULL UNIQUE,
    FOREIGN KEY (projeto_id) REFERENCES projeto(id) ON DELETE CASCADE
);

-- Tabela para listar os membros de cada equipe de projeto e seus papéis.
CREATE TABLE membro_equipe (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    papel_na_equipe VARCHAR(255) NOT NULL,
    data_entrada_equipe DATE NOT NULL,
    equipe_projeto_id BIGINT NOT NULL,
    profissional_id BIGINT NOT NULL,
    FOREIGN KEY (equipe_projeto_id) REFERENCES equipe_projeto(id) ON DELETE CASCADE,
    FOREIGN KEY (profissional_id) REFERENCES usuario(id) ON DELETE CASCADE
);

-- Tabela para armazenar mensagens trocadas na plataforma.
-- Pode ser entre usuários, ou direcionada a uma equipe de projeto, ou relacionada a um projeto específico.
CREATE TABLE mensagem (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    conteudo TEXT NOT NULL,
    data_envio TIMESTAMP NOT NULL,
    lida BOOLEAN DEFAULT FALSE,
    remetente_id BIGINT NOT NULL,
    destinatario_id BIGINT, -- Pode ser nulo se a mensagem for para uma equipe
    equipe_projeto_id_destino BIGINT, -- Pode ser nulo se a mensagem for para um usuário
    projeto_id_contexto BIGINT, -- Para vincular a mensagem a um projeto específico, se aplicável
    FOREIGN KEY (remetente_id) REFERENCES usuario(id),
    FOREIGN KEY (destinatario_id) REFERENCES usuario(id),
    FOREIGN KEY (equipe_projeto_id_destino) REFERENCES equipe_projeto(id),
    FOREIGN KEY (projeto_id_contexto) REFERENCES projeto(id)
);

-- Tabela para armazenar avaliações.
-- O campo `tipo_alvo_avaliado` indica o que está sendo avaliado (ex: 'PROFISSIONAL', 'EMPRESA', 'PROJETO').
-- O campo `alvo_id` armazena o ID correspondente ao tipo (ex: usuario.id para 'PROFISSIONAL' ou 'EMPRESA', projeto.id para 'PROJETO').
CREATE TABLE avaliacao (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nota INT NOT NULL,
    comentario TEXT,
    data_avaliacao DATE NOT NULL,
    avaliador_id BIGINT NOT NULL,
    tipo_alvo_avaliado VARCHAR(50) NOT NULL COMMENT 'Ex: ''PROFISSIONAL'', ''EMPRESA'', ''PROJETO''',
    alvo_id BIGINT NOT NULL COMMENT 'ID do usuário, projeto, etc., que está sendo avaliado',
    FOREIGN KEY (avaliador_id) REFERENCES usuario(id)
);

-- Tabela para registrar as entregas feitas em um projeto.
CREATE TABLE entrega_projeto (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    descricao_entrega TEXT NOT NULL,
    arquivo_url VARCHAR(255),
    data_submissao DATETIME NOT NULL,
    status_entrega VARCHAR(50) NOT NULL,
    projeto_id BIGINT NOT NULL,
    equipe_projeto_id BIGINT, -- Equipe que realizou a entrega (opcional, pode ser um membro individual)
    membro_equipe_id_submissao BIGINT, -- Membro específico que submeteu (opcional)
    FOREIGN KEY (projeto_id) REFERENCES projeto(id),
    FOREIGN KEY (equipe_projeto_id) REFERENCES equipe_projeto(id),
    FOREIGN KEY (membro_equipe_id_submissao) REFERENCES membro_equipe(id)
);
