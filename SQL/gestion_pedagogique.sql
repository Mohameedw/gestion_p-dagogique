-- =====================================================================
-- Application Web de Gestion Pédagogique
-- =====================================================================

CREATE DATABASE IF NOT EXISTS gestion_pedagogique
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE gestion_pedagogique;

-- =====================================================================
-- Tables
-- =====================================================================

CREATE TABLE Departement (
    id_departement INT UNSIGNED NOT NULL AUTO_INCREMENT,
    code_dept      VARCHAR(20)  NOT NULL,
    nom_dept       VARCHAR(150) NOT NULL,
    description    TEXT NULL,
    CONSTRAINT pk_departement PRIMARY KEY (id_departement),
    CONSTRAINT uq_departement_code UNIQUE (code_dept)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Formation (
    id_formation   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_departement INT UNSIGNED NOT NULL,
    code_formation VARCHAR(20)  NOT NULL,
    nom_formation  VARCHAR(150) NOT NULL,
    niveau         VARCHAR(50)  NOT NULL,
    description    TEXT NULL,
    CONSTRAINT pk_formation PRIMARY KEY (id_formation),
    CONSTRAINT uq_formation_code UNIQUE (code_formation),
    CONSTRAINT fk_formation_departement FOREIGN KEY (id_departement)
        REFERENCES Departement (id_departement)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Filiere (
    id_filiere   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_formation INT UNSIGNED NOT NULL,
    code_filiere VARCHAR(20)  NOT NULL,
    nom_filiere  VARCHAR(150) NOT NULL,
    description  TEXT NULL,
    CONSTRAINT pk_filiere PRIMARY KEY (id_filiere),
    CONSTRAINT uq_filiere_code UNIQUE (code_filiere),
    CONSTRAINT fk_filiere_formation FOREIGN KEY (id_formation)
        REFERENCES Formation (id_formation)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Annee_univ (
    id_annee   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    libelle    VARCHAR(20) NOT NULL,
    date_debut DATE NOT NULL,
    date_fin   DATE NOT NULL,
    statut     ENUM('PLANIFIEE','EN_COURS','CLOTUREE') NOT NULL DEFAULT 'PLANIFIEE',
    CONSTRAINT pk_annee_univ PRIMARY KEY (id_annee),
    CONSTRAINT uq_annee_libelle UNIQUE (libelle),
    CONSTRAINT ck_annee_dates CHECK (date_fin > date_debut)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Semestre (
    id_semestre     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero_semestre TINYINT UNSIGNED NOT NULL,
    libelle         VARCHAR(50) NOT NULL,
    CONSTRAINT pk_semestre PRIMARY KEY (id_semestre),
    CONSTRAINT uq_semestre_numero UNIQUE (numero_semestre),
    CONSTRAINT ck_semestre_numero CHECK (numero_semestre > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Utilisateur (
    id_utilisateur    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom_utilisateur   VARCHAR(100) NOT NULL,
    email             VARCHAR(150) NOT NULL,
    mot_de_passe_hash VARCHAR(255) NOT NULL,
    role              ENUM('ADMIN','ENSEIGNANT','ETUDIANT') NOT NULL,
    actif             TINYINT(1) NOT NULL DEFAULT 1,
    date_creation     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_utilisateur PRIMARY KEY (id_utilisateur),
    CONSTRAINT uq_utilisateur_email UNIQUE (email),
    CONSTRAINT ck_utilisateur_actif CHECK (actif IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Etudiant (
    id_etudiant    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_utilisateur INT UNSIGNED NOT NULL,
    CNE            VARCHAR(20)  NOT NULL,
    nom            VARCHAR(100) NOT NULL,
    prenom         VARCHAR(100) NOT NULL,
    date_naissance DATE NOT NULL,
    telephone      VARCHAR(20) NULL,
    adresse        VARCHAR(255) NULL,
    CONSTRAINT pk_etudiant PRIMARY KEY (id_etudiant),
    CONSTRAINT uq_etudiant_utilisateur UNIQUE (id_utilisateur),
    CONSTRAINT uq_etudiant_cne UNIQUE (CNE),
    CONSTRAINT fk_etudiant_utilisateur FOREIGN KEY (id_utilisateur)
        REFERENCES Utilisateur (id_utilisateur)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Enseignant (
    id_enseignant  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_utilisateur INT UNSIGNED NOT NULL,
    matricule      VARCHAR(20)  NOT NULL,
    nom            VARCHAR(100) NOT NULL,
    prenom         VARCHAR(100) NOT NULL,
    telephone      VARCHAR(20) NULL,
    specialite     VARCHAR(150) NULL,
    CONSTRAINT pk_enseignant PRIMARY KEY (id_enseignant),
    CONSTRAINT uq_enseignant_utilisateur UNIQUE (id_utilisateur),
    CONSTRAINT uq_enseignant_matricule UNIQUE (matricule),
    CONSTRAINT fk_enseignant_utilisateur FOREIGN KEY (id_utilisateur)
        REFERENCES Utilisateur (id_utilisateur)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Module (
    id_module   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    code_module VARCHAR(20)  NOT NULL,
    nom_module  VARCHAR(150) NOT NULL,
    description TEXT NULL,
    CONSTRAINT pk_module PRIMARY KEY (id_module),
    CONSTRAINT uq_module_code UNIQUE (code_module)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Enseignement (
    id_enseignement    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_module          INT UNSIGNED NOT NULL,
    id_enseignant      INT UNSIGNED NOT NULL,
    id_filiere         INT UNSIGNED NOT NULL,
    id_annee           INT UNSIGNED NOT NULL,
    id_semestre        INT UNSIGNED NOT NULL,
    volume_horaire     SMALLINT UNSIGNED NULL,
    coefficient_module DECIMAL(4,2) NOT NULL DEFAULT 1.00,
    statut             ENUM('PLANIFIE','EN_COURS','TERMINE') NOT NULL DEFAULT 'PLANIFIE',
    CONSTRAINT pk_enseignement PRIMARY KEY (id_enseignement),
    CONSTRAINT uq_enseignement UNIQUE (id_module, id_enseignant, id_filiere, id_annee, id_semestre),
    CONSTRAINT ck_enseignement_coef CHECK (coefficient_module > 0),
    CONSTRAINT fk_enseignement_module FOREIGN KEY (id_module)
        REFERENCES Module (id_module) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_enseignement_enseignant FOREIGN KEY (id_enseignant)
        REFERENCES Enseignant (id_enseignant) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_enseignement_filiere FOREIGN KEY (id_filiere)
        REFERENCES Filiere (id_filiere) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_enseignement_annee FOREIGN KEY (id_annee)
        REFERENCES Annee_univ (id_annee) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_enseignement_semestre FOREIGN KEY (id_semestre)
        REFERENCES Semestre (id_semestre) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Inscription (
    id_inscription   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_etudiant      INT UNSIGNED NOT NULL,
    id_filiere       INT UNSIGNED NOT NULL,
    id_annee         INT UNSIGNED NOT NULL,
    date_inscription DATE NOT NULL,
    statut           ENUM('EN_ATTENTE','VALIDEE','ANNULEE') NOT NULL DEFAULT 'VALIDEE',
    observation      TEXT NULL,
    CONSTRAINT pk_inscription PRIMARY KEY (id_inscription),
    CONSTRAINT uq_inscription_etudiant_annee UNIQUE (id_etudiant, id_annee),
    CONSTRAINT fk_inscription_etudiant FOREIGN KEY (id_etudiant)
        REFERENCES Etudiant (id_etudiant) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_inscription_filiere FOREIGN KEY (id_filiere)
        REFERENCES Filiere (id_filiere) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_inscription_annee FOREIGN KEY (id_annee)
        REFERENCES Annee_univ (id_annee) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Evaluation (
    id_evaluation   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_enseignement INT UNSIGNED NOT NULL,
    libelle         VARCHAR(150) NOT NULL,
    type_evaluation ENUM('EXAMEN','CONTROLE_CONTINU','TP','TD','PROJET','RATTRAPAGE','AUTRE') NOT NULL,
    date_evaluation DATE NULL,
    coefficient     DECIMAL(4,2) NOT NULL DEFAULT 1.00,
    note_max        DECIMAL(5,2) NOT NULL DEFAULT 20.00,
    CONSTRAINT pk_evaluation PRIMARY KEY (id_evaluation),
    CONSTRAINT ck_evaluation_coef CHECK (coefficient > 0),
    CONSTRAINT ck_evaluation_note_max CHECK (note_max > 0),
    CONSTRAINT fk_evaluation_enseignement FOREIGN KEY (id_enseignement)
        REFERENCES Enseignement (id_enseignement) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Note (
    id_note           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_evaluation     INT UNSIGNED NOT NULL,
    id_inscription    INT UNSIGNED NOT NULL,
    valeur            DECIMAL(5,2) NOT NULL,
    date_saisie       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observation       TEXT NULL,
    statut_validation ENUM('BROUILLON','VALIDEE') NOT NULL DEFAULT 'BROUILLON',
    CONSTRAINT pk_note PRIMARY KEY (id_note),
    CONSTRAINT uq_note_evaluation_inscription UNIQUE (id_evaluation, id_inscription),
    CONSTRAINT ck_note_valeur CHECK (valeur >= 0),
    CONSTRAINT fk_note_evaluation FOREIGN KEY (id_evaluation)
        REFERENCES Evaluation (id_evaluation) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_note_inscription FOREIGN KEY (id_inscription)
        REFERENCES Inscription (id_inscription) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- Vue de contrôle
-- =====================================================================

CREATE VIEW v_comptes_sans_profil AS
SELECT u.id_utilisateur, u.email, u.role
FROM Utilisateur u
LEFT JOIN Etudiant e    ON e.id_utilisateur  = u.id_utilisateur
LEFT JOIN Enseignant en ON en.id_utilisateur = u.id_utilisateur
WHERE (u.role = 'ETUDIANT'   AND e.id_etudiant    IS NULL)
   OR (u.role = 'ENSEIGNANT' AND en.id_enseignant IS NULL);

-- =====================================================================
-- Procédures et triggers
-- =====================================================================

DELIMITER $$

CREATE PROCEDURE sp_verifier_note(
    IN p_id_evaluation  INT UNSIGNED,
    IN p_id_inscription INT UNSIGNED,
    IN p_valeur         DECIMAL(5,2)
)
BEGIN
    DECLARE v_note_max    DECIMAL(5,2);
    DECLARE v_filiere_ens INT UNSIGNED;
    DECLARE v_annee_ens   INT UNSIGNED;
    DECLARE v_filiere_ins INT UNSIGNED;
    DECLARE v_annee_ins   INT UNSIGNED;
    DECLARE v_statut_ins  VARCHAR(20);

    SELECT ev.note_max, en.id_filiere, en.id_annee
      INTO v_note_max, v_filiere_ens, v_annee_ens
      FROM Evaluation ev
      JOIN Enseignement en ON en.id_enseignement = ev.id_enseignement
     WHERE ev.id_evaluation = p_id_evaluation;

    SELECT id_filiere, id_annee, statut
      INTO v_filiere_ins, v_annee_ins, v_statut_ins
      FROM Inscription
     WHERE id_inscription = p_id_inscription;

    IF v_filiere_ins <> v_filiere_ens OR v_annee_ins <> v_annee_ens THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Note refusee : inscription incompatible avec la filiere ou l''annee de l''enseignement';
    END IF;

    IF v_statut_ins <> 'VALIDEE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Note refusee : l''inscription de l''etudiant n''est pas validee';
    END IF;

    IF p_valeur < 0 OR p_valeur > v_note_max THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Note refusee : la valeur doit etre comprise entre 0 et note_max';
    END IF;
END$$

CREATE PROCEDURE sp_verifier_role_profil(
    IN p_id_utilisateur INT UNSIGNED,
    IN p_role_attendu   VARCHAR(20)
)
BEGIN
    DECLARE v_role VARCHAR(20);

    SELECT role INTO v_role
      FROM Utilisateur
     WHERE id_utilisateur = p_id_utilisateur;

    IF v_role <> p_role_attendu THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Profil refuse : le role de l''utilisateur ne correspond pas au type de profil';
    END IF;
END$$

CREATE TRIGGER trg_note_bi BEFORE INSERT ON Note
FOR EACH ROW
BEGIN
    CALL sp_verifier_note(NEW.id_evaluation, NEW.id_inscription, NEW.valeur);
END$$

CREATE TRIGGER trg_note_bu BEFORE UPDATE ON Note
FOR EACH ROW
BEGIN
    CALL sp_verifier_note(NEW.id_evaluation, NEW.id_inscription, NEW.valeur);
END$$

CREATE TRIGGER trg_inscription_bu BEFORE UPDATE ON Inscription
FOR EACH ROW
BEGIN
    IF (NEW.id_filiere <> OLD.id_filiere OR NEW.id_annee <> OLD.id_annee)
       AND EXISTS (SELECT 1 FROM Note WHERE id_inscription = OLD.id_inscription) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Modification refusee : des notes existent pour cette inscription';
    END IF;

    IF OLD.statut = 'VALIDEE' AND NEW.statut <> 'VALIDEE'
       AND EXISTS (SELECT 1 FROM Note WHERE id_inscription = OLD.id_inscription) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Statut refuse : cette inscription validee possede deja des notes';
    END IF;
END$$

CREATE TRIGGER trg_evaluation_bu BEFORE UPDATE ON Evaluation
FOR EACH ROW
BEGIN
    IF NEW.id_enseignement <> OLD.id_enseignement
       AND EXISTS (SELECT 1 FROM Note WHERE id_evaluation = OLD.id_evaluation) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Modification refusee : des notes existent pour cette evaluation';
    END IF;

    IF NEW.note_max < OLD.note_max
       AND EXISTS (SELECT 1 FROM Note
                    WHERE id_evaluation = OLD.id_evaluation
                      AND valeur > NEW.note_max) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Modification refusee : des notes depassent la nouvelle note_max';
    END IF;
END$$

CREATE TRIGGER trg_enseignement_bu BEFORE UPDATE ON Enseignement
FOR EACH ROW
BEGIN
    IF (NEW.id_module     <> OLD.id_module
        OR NEW.id_enseignant <> OLD.id_enseignant
        OR NEW.id_filiere    <> OLD.id_filiere
        OR NEW.id_annee      <> OLD.id_annee
        OR NEW.id_semestre   <> OLD.id_semestre)
       AND EXISTS (SELECT 1
                     FROM Note n
                     JOIN Evaluation ev ON ev.id_evaluation = n.id_evaluation
                    WHERE ev.id_enseignement = OLD.id_enseignement) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Modification refusee : des notes existent pour cet enseignement';
    END IF;
END$$

CREATE TRIGGER trg_etudiant_bi BEFORE INSERT ON Etudiant
FOR EACH ROW
BEGIN
    CALL sp_verifier_role_profil(NEW.id_utilisateur, 'ETUDIANT');
END$$

CREATE TRIGGER trg_etudiant_bu BEFORE UPDATE ON Etudiant
FOR EACH ROW
BEGIN
    CALL sp_verifier_role_profil(NEW.id_utilisateur, 'ETUDIANT');
END$$

CREATE TRIGGER trg_etudiant_bd BEFORE DELETE ON Etudiant
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Utilisateur
                WHERE id_utilisateur = OLD.id_utilisateur AND role = 'ETUDIANT') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Suppression refusee : supprimez le compte utilisateur, le profil suivra';
    END IF;
END$$

CREATE TRIGGER trg_enseignant_bi BEFORE INSERT ON Enseignant
FOR EACH ROW
BEGIN
    CALL sp_verifier_role_profil(NEW.id_utilisateur, 'ENSEIGNANT');
END$$

CREATE TRIGGER trg_enseignant_bu BEFORE UPDATE ON Enseignant
FOR EACH ROW
BEGIN
    CALL sp_verifier_role_profil(NEW.id_utilisateur, 'ENSEIGNANT');
END$$

CREATE TRIGGER trg_enseignant_bd BEFORE DELETE ON Enseignant
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Utilisateur
                WHERE id_utilisateur = OLD.id_utilisateur AND role = 'ENSEIGNANT') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Suppression refusee : supprimez le compte utilisateur, le profil suivra';
    END IF;
END$$

CREATE TRIGGER trg_utilisateur_bu BEFORE UPDATE ON Utilisateur
FOR EACH ROW
BEGIN
    IF NEW.role <> OLD.role
       AND (EXISTS (SELECT 1 FROM Etudiant   WHERE id_utilisateur = OLD.id_utilisateur)
         OR EXISTS (SELECT 1 FROM Enseignant WHERE id_utilisateur = OLD.id_utilisateur)) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Changement de role refuse : un profil est deja rattache a ce compte';
    END IF;
END$$

DELIMITER ;
