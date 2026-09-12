# 用 CS169 的方式理解这个项目

这就是 Ruby on Rails 项目，不需要学习 React 或 Next.js 才能读代码。

## MVC：从点击 Save draft 开始

1. **View**：`app/views/applications/show.html.erb` 用 ERB 生成表单。`form_with` 自动带上 CSRF token。点击 Save draft 后，浏览器发送 POST 或 PATCH。
2. **Router**：`config/routes.rb` 把请求交给 `ApplicationsController#create` 或 `#update`。
3. **Controller**：先确认登录，再通过 `current_user.hack_application` 找自己的申请；strong parameters 只接收允许修改的答案，不能接收用户伪造的 user_id、role 或 status。
4. **Model**：`HackApplication` 负责字段长度、链接和提交完整性验证。Active Record 把 `save` 翻译成数据库语句。
5. **View**：成功后 redirect 回申请页，展示保存提示、答案和状态。验证失败时重新 render 表单和错误，不写入无效数据。

这和课上 Rails CRUD 的流程一致，只是资源从 Movie 变成了 User、HackApplication、Review。

## Model 的关联

- `User has_one :hack_application`：一个账号对应一份本角色的申请。
- `HackApplication belongs_to :user`：申请有明确所有者。
- `HackApplication has_one :review`：每份申请保留一份当前评分。
- `Review belongs_to :reviewer, class_name: "User"`：知道是谁评分的。
- `User has_many :login_sessions`：账号可以在不同浏览器登录。

数据库 migration 创建表、唯一索引和外键。Model 验证帮助展示清晰错误；数据库约束负责最后一道一致性检查。

## 邮箱密码登录怎么工作

注册使用 Rails 的 `has_secure_password`。bcrypt 加盐后生成 `password_digest`，数据库不存明文密码。登录用 `authenticate_by` 校验邮箱和密码。

登录成功后，服务器生成随机 token，将它的 SHA-256 摘要存入 `LoginSession`；浏览器保存加密 Cookie。以后每次请求查找有效会话，就能得到 `current_user`。退出时删除会话，因此旧 Cookie 无法继续使用。登录和注册还有每个邮箱 15 分钟 10 次的数据库计数限制。

Organizer 也用邮箱密码登录。只有注册时提供服务器上的 `ORGANIZER_INVITE_CODE` 才能创建该角色，这避免普通申请者随意获取审核权限。

## 为什么要有 lock_version 和 transaction

两个标签页同时编辑时，旧页面不能覆盖新答案。Rails 的 optimistic locking 使用 `lock_version` 检查保存时版本是否仍然相同。

审核还使用 `with_lock`：锁住申请，检查页面版本，再在同一个 transaction 中保存评分和状态。任一验证失败就全部回滚，不会出现「评分没存，状态却改了」。

## TDD / BDD

- RSpec request specs 覆盖完整请求流程、授权、密码、草稿、提交、评分和并发编辑。
- Cucumber 用 Given / When / Then 描述用户行为，并通过 Capybara 操作真实 Rails 表单。
- 本地测试数据库用 SQLite；生产部署用 PostgreSQL。Active Record 让业务代码使用同一组模型接口。
- 不把测试数据写入生产数据库，也没有网站演示模式。

建议面试时从「保存草稿」走一遍 MVC，再解释权限检查、Active Record 关联和一个 Cucumber scenario。不要背代码；尝试自己改一个字段或验证条件，再跑测试看结果。
