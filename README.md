# Heroku-PagerMaid

## Heroku Button 图形化在线部署

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

> 注意不要搞混 session、api_key、api_hash 这三个环境变量

## 特点

 - 部署简单方便，无需国外服务器
 - pingdc 的延迟极低
 ![pingdc](https://s3.bmp.ovh/imgs/2022/03/26df8e3edc351d6e.jpg)
 _提示：因为权限问题 pingdc 命令无法在 heroku 部署的 PagerMaid 上正常使用，此处使用了下文的特殊技巧_
 ![speedtest](https://s3.bmp.ovh/imgs/2022/03/e41b8cf0fe549d0e.jpg)
 - 无需刻意升级 PagerMaid，因为重新构建即是最新
 - 无需担心长期开着 PagerMaid 导致账号异常等
 - 无需担心恶意插件损坏服务器等

## 已知问题

- 不支持需要 sudo 的操作
- 因为权限问题不支持 redis 数据库，可能导致**部分插件命令无法使用**，或功能异常
- [30 分钟自动休眠](https://devcenter.heroku.com/articles/free-dyno-hours#dyno-sleeping)，**需要手动访问 Web 页面来唤醒**（PagerMaid 需要不到一分钟的时间来启动）
- 因为自动休眠的机制，需要一直挂机的功能无法使用
- PagerMaid **重启即丢失所有配置和插件**，添加插件比较麻烦
- 设置的 session 可能会过期（取决于你的 Telegram 设置），需要重新获取并修改 session 环境变量
- Heroku Dyno 免费内存仅 512M，运行消耗大量内存的任务（例如 groupword）时可能 OOM
- 其它上游 PagerMaid 的问题在这里一样有

## 修改配置和添加插件

你可以直接在环境变量中设置字符串形式的 session、api_key、api_hash，并且环境变量的优先级高于配置文件

1. 在你的 Github 中 [fork](https://docs.github.com/cn/get-started/quickstart/fork-a-repo) 本仓库
2. 在你部署的 Heroku App 中[连接到刚才 fork 的 Github 仓库](https://devcenter.heroku.com/articles/github-integration)，启用 Automatic Deploys 自动部署
3. 以后就可以直接在 fork 的 Github 仓库中修改配置文件和添加插件了

配置文件在仓库的 /workdir/config.yml 中。可以在 /workdir/plugins/ 中添加插件，插件从[这里](https://gitlab.com/Xtao-Labs/PagerMaid_Plugins)获取。

事实上，**所有 workdir 中的内容都会添加到 Docker 容器中**。特别的，如果插件需要 Python 依赖，请将依赖添加到 /workdir/plugins/requirements.txt 它会在构建时安装

## 特殊技巧：让 PagerMaid 不自动休眠

为了节约你的免费 Dyno 时间，免费用户的 Dyno 会[自动休眠](https://devcenter.heroku.com/articles/free-dyno-hours#dyno-sleeping)。但仍可以通过一些手段让其 24 小时运行。切记：不绑定信用卡，每月免费的 Dyno 时间仅有 550 小时，约合 22.91 天，**24 小时运行将极快地浪费你的 Dyno 时间**

### 几种方法

- 不修改文件，只是使用 [UptimeRobot](https://uptimerobot.com) 等网页监控工具轮训 Web 页面即可
- 将 [Dyno configuration](https://devcenter.heroku.com/articles/dynos#dyno-configurations) 设为 Worker。即 heroku.yml 中的 `build: docker: web: Dockerfile run: web: python -m pagermaid` 改为 `build: worker: docker: Dockerfile run: worker: python -m pagermaid`。这种方法会导致没有 Web 页面

## 特殊技巧：支持 sudo、redis

虽然通常情况下 Heroku Dyno 无法运行 sudo 命令，但仍可以通过一些手段让其支持。但这是**不建议的操作**，且有着更多的限制，这里说明基本步骤

> 需要有安装了 [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) 的环境

### 如何

主要原理是 虽然运行中的 Heroku Dyno 无法运行 sudo 命令，但构建时是可以的。所以要在**构建时运行 PagerMaid**

1. 在 Dockerfile 中添加启动 PagerMaid 的命令，（没错，在 Dockerfile 中添加）
大概是这样：`RUN service redis-server start && python -m pagermaid` 这里还添加了启动 redis
2. 在 heroku.yml 中删去启动 PagerMaid 的部分
即：`run: web: python -m pagermaid`（或关闭 Dyno）
3. 应该就可以使用 sudo 了，但请务必注意以下的限制

### 限制

- Heroku 的构建时间限制为 [15 分钟](https://devcenter.heroku.com/articles/limits#slug-compilation)（而不是 Dyno 休眠的 30 分钟，而且无法延长构建时间限制）
- 构建超时后构建不会自动结束，PagerMaid 此时未运行，在网页控制台没有手动取消构建的方式，免费用户也只能同时进行一个构建。**你会因此卡在这里**
- 每次启动 PagerMaid 都需要命令行操作手动取消构建，还需要等 5 分钟左右从头构建（而不是不到一分钟的只启动时间）
- 没有 Web 页面

### 使用命令行手动取消构建

1. 先使用 Heroku CLI 将 Hueroku 存储库（不是连接到的 Github 存储库）[克隆到本地](https://devcenter.heroku.com/articles/git-clone-heroku-app)
2. 使用 `heroku plugins:install heroku-builds` 安装 Heroku CLI 的 [Heroku Builds 插件](https://github.com/heroku/heroku-builds)
3. 现在可以使用 `heroku builds:cancel` 手动取消构建
