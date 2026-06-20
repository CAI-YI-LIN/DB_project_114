# 教室借用管理系統

> 國立虎尾科技大學 資訊工程系｜資料庫系統期末專題 G03

---

## 應用情境

大專院校中，教室除正式課程外，廣泛用於社團會議、專題討論、補課、講座等活動。傳統紙本登記方式容易造成資訊不同步與借用衝突，本系統透過資料庫集中管理，提供：

- 即時教室可用狀態查詢
- 線上借用申請與自動衝堂檢查
- 管理員審核流程
- 歷史借用紀錄與設備管理

---

## 使用案例

### 使用者（學生 / 教師）

| 功能 | 說明 |
|------|------|
| 查詢教室 | 依日期、時間、設備需求篩選可用教室 |
| 申請借用 | 填寫時間、教室、用途，系統自動檢查衝堂 |
| 取消借用 | 僅可取消尚未開始的申請（本人操作） |
| 查看紀錄 | 查詢個人或特定教室的歷史借用紀錄 |

### 管理員（Admin）

| 功能 | 說明 |
|------|------|
| 審核申請 | Pending → Approved / Rejected（拒絕須填原因） |
| 教室管理 | 新增、停用教室，設定維修中狀態 |
| 設備管理 | 新增或修改各教室的設備資訊 |

---

## 資料庫設計

### 資料表概覽

| 資料表 | 說明 |
|--------|------|
| `User` | 使用者（Student / Teacher / Admin） |
| `Room` | 教室資訊與狀態（Normal / UnderMaintenance） |
| `Equipment` | 教室設備，與教室一對多關聯 |
| `BorrowRequest` | 借用申請（Pending / Approved / Rejected / Cancelled） |
| `AuditLog` | 審核歷程紀錄 |

### 關聯結構

```
User ──────── BorrowRequest ──── AuditLog
                   │                │
Room ──────────────┘         (admin_id → User)
 │
Equipment
```

### 完整 SQL 建表語法

```sql
CREATE TABLE User (
    user_id       INT          NOT NULL AUTO_INCREMENT,
    name          VARCHAR(50)  NOT NULL,
    phone         VARCHAR(10)  NULL,
    account       VARCHAR(20)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(10)  NOT NULL,
    PRIMARY KEY (user_id),
    CHECK (role IN ('Student', 'Teacher', 'Admin')),
    CHECK (LENGTH(account) >= 4)
);

CREATE TABLE Room (
    room_id   INT          NOT NULL AUTO_INCREMENT,
    room_name VARCHAR(20)  NOT NULL UNIQUE,
    location  VARCHAR(50)  NULL,
    capacity  INT          NOT NULL,
    status    VARCHAR(20)  NOT NULL DEFAULT 'Normal',
    PRIMARY KEY (room_id),
    CHECK (capacity BETWEEN 1 AND 100),
    CHECK (status IN ('Normal', 'UnderMaintenance'))
);

CREATE TABLE Equipment (
    eq_id   INT         NOT NULL AUTO_INCREMENT,
    eq_name VARCHAR(30) NOT NULL,
    room_id INT         NOT NULL,
    PRIMARY KEY (eq_id),
    UNIQUE (eq_name, room_id),
    FOREIGN KEY (room_id) REFERENCES Room(room_id) ON DELETE CASCADE
);

CREATE TABLE BorrowRequest (
    req_id      INT          NOT NULL AUTO_INCREMENT,
    user_id     INT          NOT NULL,
    room_id     INT          NOT NULL,
    borrow_date DATE         NOT NULL,
    start_time  TIME         NOT NULL,
    end_time    TIME         NOT NULL,
    purpose     VARCHAR(100) NOT NULL,
    borrow_type VARCHAR(10)  NOT NULL,
    status      VARCHAR(10)  NOT NULL DEFAULT 'Pending',
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (req_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (room_id) REFERENCES Room(room_id),
    CHECK (start_time < end_time),
    CHECK (borrow_type IN ('ShortTerm', 'LongTerm')),
    CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Cancelled'))
);

CREATE TABLE AuditLog (
    log_id    INT          NOT NULL AUTO_INCREMENT,
    req_id    INT          NOT NULL,
    admin_id  INT          NOT NULL,
    action    VARCHAR(10)  NOT NULL,
    reason    VARCHAR(200) NULL,
    timestamp DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (log_id),
    FOREIGN KEY (req_id)   REFERENCES BorrowRequest(req_id),
    FOREIGN KEY (admin_id) REFERENCES User(user_id),
    CHECK (action IN ('Approve', 'Reject'))
);
```

### 主要完整性限制

- 同一教室、同一日期的 Approved 借用申請，時間區間不可重疊
- 教室狀態為 `UnderMaintenance` 時，不可核准任何借用申請
- 只有 `role = 'Admin'` 的使用者可以審核申請
- 借用取消只能由申請人本人操作，且不得超過借用開始時間
- `action = 'Reject'` 時，`AuditLog.reason` 不可為空

---

## 資料範例

### 借用申請情境

管理員張小明審核教師王老師借用 BGC0614 教室的申請並核准；另一筆學生申請因時段衝突遭拒絕。

```sql
-- 使用者
INSERT INTO User (name, phone, account, password_hash, role) VALUES
('張小明', '0912345678', 'admin01',      'e3b0c44298fc1c149afb', 'Admin'),
('李同學', '0987654321', 'std41243101',  'abc123hashvalue',      'Student'),
('王老師', '0933111222', 'teacher_wang', 'xyz789hashvalue',      'Teacher');

-- 教室
INSERT INTO Room (room_name, location, capacity, status) VALUES
('BGC0614', '綜三館 6F', 60, 'Normal'),
('BGC0513', '綜三館 5F', 60, 'UnderMaintenance'),
('BGC0501', '綜三館 5F', 60, 'Normal');

-- 借用申請
INSERT INTO BorrowRequest (user_id, room_id, borrow_date, start_time, end_time, purpose, borrow_type, status) VALUES
(3, 1, '2026-06-10', '09:00', '12:00', '補課',         'ShortTerm', 'Approved'),
(2, 1, '2026-06-10', '09:00', '10:00', '小組報告練習', 'ShortTerm', 'Rejected'),
(2, 3, '2026-06-15', '10:00', '11:00', '專題討論',     'ShortTerm', 'Pending');

-- 審核紀錄
INSERT INTO AuditLog (req_id, admin_id, action, reason) VALUES
(1, 1, 'Approve', NULL),
(2, 1, 'Reject',  '申請時段與已核准之教室借用申請衝突，無法核准借用申請');
```

---

## 團隊成員

| 學號 | 姓名 |
|------|------|
| 41243101 | 伍翊瑄 |
| 41243103 | 林采儀 |
| 41243104 | 范芷紜 |
| 41243107 | 潘怡潔 |

---

> 國立虎尾科技大學 資訊工程系｜資料庫系統課程
