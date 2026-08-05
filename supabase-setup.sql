-- ============================================================
-- 小世界·亲情圈 Supabase 建表 SQL
-- 使用方法：前往 supabase.com 创建免费项目，
-- 在 Dashboard → SQL Editor 中粘贴并执行以下全部内容
-- ============================================================

-- 1. 创建亲情圈房间表
CREATE TABLE IF NOT EXISTS family_rooms (
  room_code    TEXT PRIMARY KEY,
  room_name    TEXT,
  baby_nickname TEXT,
  created_by   TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 创建宝宝相册条目表
CREATE TABLE IF NOT EXISTS album_entries (
  id          TEXT PRIMARY KEY,
  room_code   TEXT REFERENCES family_rooms(room_code) ON DELETE CASCADE,
  photos      JSONB DEFAULT '[]'::JSONB,
  text        TEXT,
  date        TEXT,
  tags        JSONB DEFAULT '[]'::JSONB,
  template    TEXT,
  created_by  TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 3. 启用行级安全 (RLS)
ALTER TABLE family_rooms   ENABLE ROW LEVEL SECURITY;
ALTER TABLE album_entries  ENABLE ROW LEVEL SECURITY;

-- 4. 创建访问策略
--    原型阶段允许匿名读写，生产环境请收紧为认证用户专属策略
CREATE POLICY "allow_all_family_rooms"  ON family_rooms  FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_album_entries" ON album_entries FOR ALL USING (true) WITH CHECK (true);

-- 5. 自动更新 updated_at 字段
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS album_entries_updated_at ON album_entries;
CREATE TRIGGER album_entries_updated_at
  BEFORE UPDATE ON album_entries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- 完成后，在 Dashboard → Settings → API 中找到：
--   - Project URL（形如 https://xxxxx.supabase.co）
--   - anon public key（一长串 eyJ... 开头的字符串）
-- 将这两个值填入小世界「自定义」页面 → 亲情圈 → 配置云端同步
-- ============================================================
