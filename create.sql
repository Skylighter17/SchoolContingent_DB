-- Child - main information about children
CREATE TABLE Child (
    child_id SERIAL PRIMARY KEY,
    birth_date DATE NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female')),
    citizenship VARCHAR(50) NOT NULL
);

-- Representative table - main information about parent/caretaker
CREATE TABLE Representative (
    representative_id SERIAL PRIMARY KEY,
    birth_date DATE NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female')),
    citizenship VARCHAR(50) NOT NULL
);


-- Representation association table (M:N)
CREATE TABLE Representation (
    representation_id SERIAL PRIMARY KEY,
    representation_type VARCHAR(50) NOT NULL,
    verification_status VARCHAR(50),
    child_id INT NOT NULL REFERENCES Child(child_id) ON DELETE CASCADE,
    representative_id INT NOT NULL REFERENCES Representative(representative_id) ON DELETE CASCADE
);

-- ChildDocument
CREATE TABLE ChildDocument (
    document_id SERIAL PRIMARY KEY,
    document_type VARCHAR(50) NOT NULL,
    series VARCHAR(20) NOT NULL,
    number VARCHAR(50) NOT NULL,
    issue_date DATE NOT NULL,
    issued_by VARCHAR(255) NOT NULL,
    child_id INT NOT NULL REFERENCES Child(child_id) ON DELETE CASCADE
);

-- RepresentativeDocument
CREATE TABLE RepresentativeDocument (
    document_id SERIAL PRIMARY KEY,
    document_type VARCHAR(50) NOT NULL,
    series VARCHAR(20) NOT NULL,
    number VARCHAR(50) NOT NULL,
    issue_date DATE NOT NULL,
    issued_by VARCHAR(255) NOT NULL,
    representative_id INT NOT NULL REFERENCES Representative(representative_id) ON DELETE CASCADE
);

-- School table - main information about educational institution
CREATE TABLE School (
    school_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    school_type VARCHAR(50) NOT NULL
);

-- Application table - main entity of database
CREATE TABLE Application (
    application_id SERIAL PRIMARY KEY,
    application_date DATE NOT NULL,
    application_source VARCHAR(50) NOT NULL,
    type VARCHAR(50),
    status VARCHAR(50) CHECK (status IN ('Принято', 'На рассмотрении', 'Отклонено')),
    school_id INT NOT NULL REFERENCES School(school_id),
    child_id INT NOT NULL REFERENCES Child(child_id),
    representative_id INT NOT NULL REFERENCES Representative(representative_id)
);

-- Class table with self-referential relationship
CREATE TABLE Class (
    class_id SERIAL PRIMARY KEY,
    class_name VARCHAR(50) NOT NULL,
    location VARCHAR(50) NOT NULL,
    future_class_id INT REFERENCES Class(class_id)
);

-- PersonalRecord - main information about students in school
-- (1:1) Relationship, personal record based on the single application,
-- this application transform into personal record by application order
CREATE TABLE PersonalRecord (
    record_id SERIAL PRIMARY KEY,
    creation_date DATE NOT NULL,
    education_form VARCHAR(50) NOT NULL,
    learning_form VARCHAR(50) NOT NULL,
    benefit VARCHAR(50),
    application_id INT UNIQUE NOT NULL REFERENCES Application(application_id) ON DELETE CASCADE,
    class_id INT NOT NULL REFERENCES Class(class_id)
);


-- Graduate table - information about graduated students
-- (1:1) relationship, because student become graduate after graduation
CREATE TABLE Graduate (
    graduate_id SERIAL PRIMARY KEY,
    education_level VARCHAR(50) NOT NULL,
    graduation_date DATE NOT NULL,
    record_id INT UNIQUE NOT NULL REFERENCES PersonalRecord(record_id) ON DELETE CASCADE
);

-- Diplo,a table - information about educational documents
CREATE TABLE Diploma (
    diploma_id SERIAL PRIMARY KEY,
    series VARCHAR(20) NOT NULL,
    number VARCHAR(50) NOT NULL,
    issue_date DATE NOT NULL,
    diploma_name VARCHAR(100) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('Оригинал', 'Дубликат')),
    graduate_id INT NOT NULL REFERENCES Graduate(graduate_id) ON DELETE CASCADE
);


-- OrderReason table, which helps to standardize academical orders
CREATE TABLE OrderReason (
    reason_id SERIAL PRIMARY KEY,
    reason_name VARCHAR(50) NOT NULL UNIQUE
);

-- AcademicOrder table, which helps to make actions with students
CREATE TABLE AcademicOrder (
    order_id SERIAL PRIMARY KEY,
    issue_date DATE NOT NULL,
    order_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) CHECK (status IN ('Черновик', 'Издан')),
    reason_id INT NOT NULL REFERENCES OrderReason(reason_id),
    basis VARCHAR(50) NOT NULL
);

-- Create "OrderParticipation" association table (M:N)
CREATE TABLE OrderParticipation (
    id SERIAL PRIMARY KEY,
    record_id INT NOT NULL REFERENCES PersonalRecord(record_id) ON DELETE CASCADE,
    order_id INT NOT NULL REFERENCES AcademicOrder(order_id) ON DELETE CASCADE
);



/*DROP TABLE IF EXISTS OrderParticipation;
DROP TABLE IF EXISTS AcademicOrder;
DROP TABLE IF EXISTS Diploma;
DROP TABLE IF EXISTS OrderReason;
DROP TABLE IF EXISTS Graduate;
DROP TABLE IF EXISTS PersonalRecord;
DROP TABLE IF EXISTS Application;
DROP TABLE IF EXISTS Class;
DROP TABLE IF EXISTS School;
DROP TABLE IF EXISTS RepresentativeDocument;
DROP TABLE IF EXISTS ChildDocument;
DROP TABLE IF EXISTS Representation;
DROP TABLE IF EXISTS Representative;
DROP TABLE IF EXISTS Child;*/

