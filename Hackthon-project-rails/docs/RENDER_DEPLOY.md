# 在 Render 发布 Rails 项目

仓库：<https://github.com/Judithandprey/hackthon-project>

[打开部署页](https://dashboard.render.com/blueprint/new?repo=https://github.com/Judithandprey/hackthon-project)

1. 确认 GitHub 仓库是 `Judithandprey/hackthon-project`，分支为 `main`。
2. Blueprint 会读取仓库根目录 `render.yaml`。应出现 Ruby Web Service 和 PostgreSQL，两项均配置为 Free。
3. 在 Blueprint 的 `ORGANIZER_INVITE_CODE` 输入框填入私密邀请码（至少 32 个字符）。应用配置后，等待 web service 状态变为 **Live**。其公开网址显示在服务页顶部。
4. 打开网站，注册 Hacker 或 Mentor，填写并提交申请。
5. 保存部署时填写的 `ORGANIZER_INVITE_CODE`，也可以在 Render web service → Environment 中查看。不要把它粘贴进 GitHub 或录屏。
6. 退出申请者账号，再用另一个邮箱注册 Organizer，填写邀请码。进入 Organizer workspace 审核刚提交的申请。
7. 重新登录申请者账号，确认能看到更新后的状态。

`DATABASE_URL` 从 PostgreSQL 自动注入；`SECRET_KEY_BASE` 由 Render 生成；邀请码通过部署表单单独填写。`bin/render-start.sh` 在启动前运行数据库 migration。数据库是空的，不会插入示例申请。

免费数据库会在 30 天后过期，免费网页服务空闲时可能休眠；录屏前先打开网页让服务唤醒。详情见 [Render 免费方案](https://render.com/docs/free)。如果页面要求付费，先检查免费额度与现有数据库，不要直接确认收费。

若发布失败，查看 Logs 的第一条实际错误。检查 Ruby 版本、Gemfile.lock、DATABASE_URL 与 SECRET_KEY_BASE，然后修复代码或环境变量，再重新部署。
