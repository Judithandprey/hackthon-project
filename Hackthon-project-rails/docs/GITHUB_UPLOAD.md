# 把源码上传到新仓库

目标仓库是 `Judithandprey/hackthon-project`。连接器目前能读仓库，但写入被 GitHub 返回 403。下面通过你电脑上自己的 Git 登录上传，不需要把密码或 token 发给任何人。

1. 解压源码 ZIP。
2. 在 Terminal 进入解压得到的 `Hackthon-project-rails` 文件夹。
3. 运行：

```sh
bash bin/publish-github.sh
```

脚本初始化本地 Git、提交源码、推送 main，不会强制覆盖远端历史。Git 如果要求登录，使用你平时 CS169 项目所用的本地 Git/GitHub 登录方式。

也可以直接打开 GitHub 仓库，使用 **uploading an existing file / Add file → Upload files**。上传解压文件夹里面的内容，确保 `Gemfile`、`Gemfile.lock`、`render.yaml` 都在仓库根目录。不要把 ZIP 本身当成源码上传。Mac Finder 可用 Command+Shift+. 显示隐藏文件，一并保留 `.ruby-version` 和 `.gitignore`。

上传后打开 README 中的 Render Blueprint 链接，填写私密邀请码，然后发布。
