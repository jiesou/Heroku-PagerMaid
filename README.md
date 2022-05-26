# PagerMaid-Pyro for Heroku

## Heroku Button - 在线部署

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## 特点

 - 部署简单方便，无需国外服务器
 - 无需担心长期开着 PagerMaid 导致账号异常等
 - 无需担心恶意插件损坏服务器等

## 已知问题

同 [PagerMaid-Modify for Heroku](https://github.com/jiesou/Heroku-PagerMaid/tree/main#已知问题)

## Web 仪表盘

PagerMaid-Pyro for Heroku 含有一个简易 Web 仪表盘，仅用于绑定 80 端口防止 Heroku 自动终止 Dyno 和方便启动 PagerMaid（打开 Web 仪表盘即启动 PagerMaid）

## 修改配置和添加插件

你可以直接在环境变量中设置字符串形式的 session、api hash、api id [等配置](https://github.com/TeamPGM/PagerMaid-Pyro/blob/master/pagermaid/config.py)，并且环境变量的优先级高于配置文件

其它内容同 [PagerMaid-Modify for Heroku](https://github.com/jiesou/Heroku-PagerMaid/tree/main)
