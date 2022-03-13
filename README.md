# Heroku-PagerMaid

## Heroku Button

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## 特点

部署简单方便，无需自备国外服务器。且 pingdc 的延迟极低。无需刻意升级 PagerMaid，因为重新构建即是最新

## 已知问题

- 因为权限问题不支持 redis 数据库，可能导致部分插件命令无法使用，或功能异常
- 30 分钟自动休眠，需要一直挂机的功能无法使用（你可以用别的服务例如 GithubAction 弄个自动唤醒，但这会浪费你的免费 Dyno 时间）详见[此处](https://devcenter.heroku.com/articles/free-dyno-hours)
- PagerMaid 无法重启，添加插件比较麻烦
- 设置的 session 可能会过期，需要重新获取并修改 session 环境变量

## 修改配置和添加插件

你可以直接在环境变量中设置字符串形式的 session、api id、api hash/key，并且环境变量的优先级高于配置文件

1. 在你的 Github 中 [fork](https://docs.github.com/cn/get-started/quickstart/fork-a-repo) 本仓库
2. 在你部署的 Heroku App 中[连接到刚才 fork 的 Github 仓库](https://devcenter.heroku.com/articles/github-integration)，建议启用 Automatic Deploys 自动部署
3. 以后就可以直接在 fork 的 Github 仓库中修改配置文件和添加插件了

配置文件在仓库的 /workdir/config.yml 中。可以在 /workdir/plugins/ 中添加插件，插件从[这里](https://gitlab.com/Xtao-Labs/PagerMaid_Plugins)获取。事实上，所有 workdir 中的内容都会添加到 Docker 容器中。
特别的，如果插件需要 Python 依赖，请将依赖添加到 /workdir/plugins/requirements.txt 它会在构建时安装
