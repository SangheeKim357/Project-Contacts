create database team;
CREATE TABLE contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    home VARCHAR(20) ,
    company VARCHAR(20) ,
    email VARCHAR(100),
    `group` VARCHAR(50),
    memo TEXT,
    address VARCHAR(255),
    birthday DATE,
    favorite BOOLEAN DEFAULT FALSE,
    image VARCHAR(255),
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO contacts (name, phone, home, company, email, `group`, memo, address, birthday, favorite, image)
VALUES 
('이경호', '010-1234-5678', '', '','ho@example.com', '친구', '고등학교 친구', '서울시 강남구', '1990-05-15', TRUE, '/images/ho.jpg'),
('김상희', '010-2345-6789', '', '', 'hee@example.com', '직장', '회사 동료', '서울시 서초구', '1988-11-03', FALSE, '/images/hee.jpg'),
('허진', '010-3456-7890', '', '', 'jin@example.com', '가족', '사촌 여동생', '부산시 해운대구', '1995-02-20', TRUE, '/images/jin.jpg'),
('장기쁨', '010-4567-8901', '', '', 'bbeum@example.com', '지인', '동호회 멤버', '대구시 수성구', '1985-08-10', FALSE, '/images/bbeum.jpg'),
('김민하', '010-5678-9012', '', '', 'ha@example.com', '가족', '사촌 언니', '인천시 연수구', '1992-12-25', TRUE, '/images/ha.jpg'),
('변제헌', '010-1111-2222', '', '', 'hun@example.com', '친구', '대학교 동기', '서울시 마포구', '1993-03-03', TRUE, '/images/hun.jpg'),
('김준혁', '010-2222-3333', '', '', 'hyuk@example.com', '지인', 'SNS에서 알게됨', '경기도 성남시', '2000-06-12', FALSE, '/images/hyuk.jpg'),
('방상현', '010-3333-4444', '', '', 'hyun@example.com', '가족', '이모', '강원도 원주시', '1975-07-15', FALSE, '/images/hyun.jpg'),
('이진우', '010-4444-5555', '', '', 'woo@example.com', '직장', '같은 부서', '서울시 동작구', '1998-09-09', TRUE, '/images/woo.jpg'),
('고경복', '010-5555-6666', '', '', 'bok@example.com', '지인', '여행 동행', '제주시 애월읍', '1990-04-21', FALSE, '/images/bok.jpg'),
('허예찬', '010-6666-7777', '', '', 'chan@example.com', '친구', '고등학교 동창', '광주시 북구', '1991-01-11', TRUE, '/images/chan.jpg'),
('정인홍', '010-7777-8888', '', '', 'hong@example.com', '직장', '프로젝트 팀원', '서울시 송파구', '1996-10-02', FALSE, '/images/hong.jpg'),
('박재형', '010-8888-9999', '', '', 'hyung@example.com', '지인', '운동 동호회', '경기도 고양시', '1989-12-30', TRUE, '/images/hyung.jpg'),
('김다은', '010-9999-0000', '', '', 'eun@example.com', '가족', '고모', '부산시 수영구', '1970-02-08', FALSE, '/images/eun.jpg'),
('윤수진', '010-0000-1111', '', '', 'sujin@example.com', '지인', '지인 소개', '서울시 종로구', '1982-08-20', TRUE, '/images/sujin.jpg');