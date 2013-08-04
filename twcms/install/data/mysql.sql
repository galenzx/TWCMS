# 用户表，可根据 uid 范围进行分区
DROP TABLE IF EXISTS pre_user;
CREATE TABLE pre_user (
  uid int(10) unsigned NOT NULL AUTO_INCREMENT,		# 用户ID
  username char(16) NOT NULL DEFAULT '',		# 用户名
  password char(32) NOT NULL DEFAULT '',		# 密码	md5(md5() + salt)
  salt char(8) NOT NULL DEFAULT '',			# 随机干扰字符，用来混淆密码
  groupid smallint(5) unsigned NOT NULL DEFAULT '0',	# 用户组
  email char(40) NOT NULL DEFAULT '',			# EMAIL
  homepage char(40) NOT NULL DEFAULT '',		# 主页的URL（外链）
  intro text NOT NULL,					# 个人介绍
  regip int(10) unsigned NOT NULL DEFAULT '0',		# 注册IP
  regdate int(10) unsigned NOT NULL DEFAULT '0',	# 注册日期
  loginip int(10) unsigned NOT NULL DEFAULT '0',	# 登陆IP
  logindate int(10) unsigned NOT NULL DEFAULT '0',	# 登陆日期
  lastip int(10) unsigned NOT NULL DEFAULT '0',		# 上次登陆IP
  lastdate int(10) unsigned NOT NULL DEFAULT '0',	# 上次登陆日期
  contents int(10) unsigned NOT NULL DEFAULT '0',	# 内容数
  uploads int(10) unsigned NOT NULL DEFAULT '0',	# 上传数
  comments int(10) unsigned NOT NULL DEFAULT '0',	# 评论数
  logins int(10) unsigned NOT NULL DEFAULT '0',		# 登陆数
  PRIMARY KEY (uid),
  UNIQUE KEY username(username),
  KEY email(email)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 后台管理用户组表
DROP TABLE IF EXISTS pre_user_group;
CREATE TABLE pre_user_group (
  groupid smallint(5) unsigned NOT NULL AUTO_INCREMENT,		# 用户组ID
  groupname char(20) NOT NULL DEFAULT '',			# 用户组名
  system tinyint(1) unsigned NOT NULL DEFAULT '0',		# 是否由系统定义 (1为系统定义，0为自定义)
  purviews text NOT NULL,					# 后台权限 (为空时不限制)
  PRIMARY KEY (groupid)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 上传附件表
DROP TABLE IF EXISTS pre_attach;
CREATE TABLE pre_attach (
  aid int(10) unsigned NOT NULL AUTO_INCREMENT,		# 附件ID
  cid smallint(5) unsigned NOT NULL DEFAULT '0',	# 分类ID
  mid tinyint(1) unsigned NOT NULL DEFAULT '0',		# 模型ID
  uid int(10) unsigned NOT NULL DEFAULT '0',		# 用户ID
  id int(10) unsigned NOT NULL DEFAULT '0',		# 内容ID
  filename char(80) NOT NULL DEFAULT '',		# 文件原名
  filetype char(7) NOT NULL DEFAULT '',			# 文件类型
  filesize int(10) unsigned NOT NULL DEFAULT '0',	# 文件大小
  filepath char(150) NOT NULL DEFAULT '',		# 文件路径
  dateline int(10) unsigned NOT NULL DEFAULT '0',	# 上传时间
  downloads int(10) unsigned NOT NULL DEFAULT '0',	# 下载次数
  isimage tinyint(1) unsigned NOT NULL DEFAULT '0',	# 是否是图片 (1为图片，0为文件。主要区分是否是可下载的附件)
  PRIMARY KEY (aid),
  KEY id (id, aid),
  KEY uid (uid, aid)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 分类栏目表
DROP TABLE IF EXISTS pre_category;
CREATE TABLE pre_category (
  cid smallint(5) unsigned NOT NULL AUTO_INCREMENT,	# 分类ID
  mid tinyint(1) unsigned NOT NULL DEFAULT '0',		# 内容模型ID
  type tinyint(1) unsigned NOT NULL DEFAULT '0',	# 分类类型 (1为列表，2为频道，3为链接)
  upid int(10) NOT NULL DEFAULT '0',			# 上级ID
  name char(30) NOT NULL DEFAULT '',			# 分类名称
  alias char(50) NOT NULL DEFAULT '',			# 唯一别名 (必填，只能是英文、数字、下划线，并且不超过50个字符，用于伪静态)
  intro char(255) NOT NULL DEFAULT '',			# 分类介绍
  cate_tpl char(80) NOT NULL DEFAULT '',		# 分类页模板
  show_tpl char(80) NOT NULL DEFAULT '',		# 内容页模板
  count int(10) unsigned NOT NULL DEFAULT '0',		# 内容数
  orderby smallint(5) NOT NULL DEFAULT '0',		# 排序
  seo_title char(80) NOT NULL DEFAULT '',		# SEO标题
  seo_keywords char(80) NOT NULL DEFAULT '',		# SEO关键词
  seo_description char(150) NOT NULL DEFAULT '',	# SEO描述
  PRIMARY KEY (cid),
  UNIQUE KEY alias (alias)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 内容模型表
DROP TABLE IF EXISTS pre_model;
CREATE TABLE pre_model (
  mid tinyint(1) unsigned NOT NULL AUTO_INCREMENT,	# 模型ID (正常情况，全站不应该超过255个模型)
  name char(10) NOT NULL DEFAULT '',			# 模型名称
  tablename char(20) NOT NULL DEFAULT '',		# 模型表名 (如: tw_cms_xxx)
  index_tpl char(80) NOT NULL DEFAULT '',		# 默认频道页模板
  cate_tpl char(80) NOT NULL DEFAULT '',		# 默认列表页模板
  show_tpl char(80) NOT NULL DEFAULT '',		# 默认内容页模板
  system tinyint(1) unsigned NOT NULL DEFAULT '0',	# 是否由系统定义 (1为系统定义，0为自定义)
  PRIMARY KEY (mid),
  UNIQUE KEY tablename (tablename)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 唯一别名表，用于伪静态 (只储存内容的别名，分类和其他别名放 kv 表)
DROP TABLE IF EXISTS pre_unique_alias;
CREATE TABLE pre_unique_alias (
  alias char(50) NOT NULL,				# 唯一别名 (只能是英文、数字、下划线)
  mid tinyint(1) unsigned NOT NULL DEFAULT '0',		# 模型ID
  id int(10) unsigned NOT NULL DEFAULT '0',		# 内容ID
  PRIMARY KEY (alias)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 单页表
DROP TABLE IF EXISTS pre_cms_page;
CREATE TABLE pre_cms_page (
  cid smallint(5) unsigned NOT NULL,			# 分类ID
  content mediumtext NOT NULL,				# 单页内容
  PRIMARY KEY (cid)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 文章表 (可根据 id 范围分区)
DROP TABLE IF EXISTS pre_cms_article;
CREATE TABLE pre_cms_article (
  cid smallint(5) unsigned NOT NULL DEFAULT '0',	# 分类ID (审核/定时发布等考虑单独设计一张表)
  id int(10) unsigned NOT NULL AUTO_INCREMENT,		# 内容ID
  title char(80) NOT NULL DEFAULT '',			# 标题
  color char(6) NOT NULL DEFAULT '',			# 标题颜色
  alias char(50) NOT NULL DEFAULT '',			# 英文别名 (用于伪静态)
  tags varchar(80) NOT NULL DEFAULT '',			# tags内容 (,号分割)
  intro varchar(255) NOT NULL DEFAULT '',		# 内容介绍
  pic varchar(255) NOT NULL DEFAULT '',			# 图片地址
  uid int(10) unsigned NOT NULL DEFAULT '0',		# 用户ID
  author varchar(20) NOT NULL DEFAULT '',		# 作者
  source varchar(150) NOT NULL DEFAULT '',		# 来源
  dateline int(10) unsigned NOT NULL DEFAULT '0',	# 发表时间
  lasttime int(10) unsigned NOT NULL DEFAULT '0',	# 更新时间
  ip int(10) unsigned NOT NULL DEFAULT '0',		# IP
  type tinyint(1) unsigned NOT NULL DEFAULT '0',	# 类型 (0为发布 1为链接)
  iscomment tinyint(1) unsigned NOT NULL DEFAULT '0',	# 是否禁止评论 (1为禁止 0为允许)
  comments int(10) unsigned NOT NULL DEFAULT '0',	# 评论数
  seo_title varchar(80) NOT NULL DEFAULT '',		# SEO标题/副标题
  seo_keywords varchar(80) NOT NULL DEFAULT '',		# SEO关键词 (没填写时读取tags)
  seo_description varchar(255) NOT NULL DEFAULT '',	# SEO描述 (没填写时读取内容摘要)
  PRIMARY KEY  (id),
  KEY cid_id (cid,id),
  KEY cid_dateline (cid,dateline)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 文章数据表 (大内容字段表，可根据 id 范围分区)
DROP TABLE IF EXISTS pre_cms_article_data;
CREATE TABLE pre_cms_article_data (
  id int(10) unsigned NOT NULL DEFAULT '0',		# 内容ID
  content mediumtext NOT NULL,				# 内容
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 文章查看数表，用来分离主表的写压力
DROP TABLE IF EXISTS pre_cms_article_views;
CREATE TABLE pre_cms_article_views (
  id int(10) unsigned NOT NULL DEFAULT '0',		# 内容ID
  cid smallint(5) unsigned NOT NULL DEFAULT '0',	# 分类ID
  views int(10) unsigned NOT NULL DEFAULT '0',		# 查看次数
  PRIMARY KEY  (id),
  KEY cid (cid,views),
  KEY views (views)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 文章最后评论表，排序使用，用来减小主表索引 (有评论时才写入)
DROP TABLE IF EXISTS pre_cms_article_lastcomment;
CREATE TABLE pre_cms_article_lastcomment (
  id int(10) unsigned NOT NULL DEFAULT '0',		# 内容ID
  cid smallint(5) unsigned NOT NULL DEFAULT '0',	# 分类ID
  lastdate int(10) unsigned NOT NULL DEFAULT '0',	# 回复时间
  PRIMARY KEY  (id),
  KEY cid (cid,lastdate),
  KEY lastdate (lastdate)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 文章评论表
DROP TABLE IF EXISTS pre_cms_article_comment;
CREATE TABLE pre_cms_article_comment (
  id int(10) unsigned NOT NULL DEFAULT '0',		# 内容ID (为负时不显示到前台,表未审核)
  commentid int(10) unsigned NOT NULL AUTO_INCREMENT,	# 评论ID
  uid int(10) unsigned NOT NULL DEFAULT '0',		# 用户ID
  author char(30) NOT NULL DEFAULT '',			# 作者，可能不等于 username
  content text NOT NULL,				# 评论内容
  ip int(10) unsigned NOT NULL DEFAULT '0',		# IP
  dateline int(10) unsigned NOT NULL DEFAULT '0',	# 发表时间
  PRIMARY KEY  (id,commentid),
  KEY ip (ip,id)	# 用来做防灌水插件
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 文章标签表
DROP TABLE IF EXISTS pre_cms_article_tag;
CREATE TABLE pre_cms_article_tag (
  tagid int(10) unsigned NOT NULL AUTO_INCREMENT,	# tagID
  name char(10) NOT NULL DEFAULT '',			# tag名称
  count int(10) unsigned NOT NULL DEFAULT '0',		# tag数量
  content text NOT NULL,				# tag内容
  PRIMARY KEY  (tagid),
  UNIQUE KEY name (name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 文章标签数据表
DROP TABLE IF EXISTS pre_cms_article_tag_data;
CREATE TABLE pre_cms_article_tag_data (
  tagid int(10) unsigned NOT NULL,			# tagID
  id int(10) unsigned NOT NULL DEFAULT '0',		# 内容ID
  PRIMARY KEY  (tagid,id)				# 排序要用id
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 持久保存的 key value 数据 (包括设置信息)
DROP TABLE IF EXISTS pre_kv;
CREATE TABLE pre_kv (
  k char(32) NOT NULL DEFAULT '',			# 键名
  v text NOT NULL DEFAULT '',				# 数据
  expiry int(10) unsigned NOT NULL DEFAULT '0',		# 过期时间
  PRIMARY KEY(k)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 缓存表
DROP TABLE IF EXISTS pre_cache;
CREATE TABLE pre_cache (
  k char(32) NOT NULL DEFAULT '',			# 键名
  v text NOT NULL DEFAULT '',				# 数据
  expiry int(10) unsigned NOT NULL DEFAULT '0',		# 过期时间
  PRIMARY KEY(k)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 记录其它表的总行数
DROP TABLE IF EXISTS pre_framework_count;
CREATE TABLE pre_framework_count (
  name char(32) NOT NULL DEFAULT '',			# 表名
  count int(10) unsigned NOT NULL DEFAULT '0',		# 总行数
  PRIMARY KEY (name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

# 记录其它表的最大ID
DROP TABLE IF EXISTS pre_framework_maxid;
CREATE TABLE pre_framework_maxid (
  name char(32) NOT NULL DEFAULT '',			# 表名
  maxid int(10) unsigned NOT NULL DEFAULT '0',		# 最大ID
  PRIMARY KEY (name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;