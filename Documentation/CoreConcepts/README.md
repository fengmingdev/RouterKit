# 核心概念

RouterKit的设计基于以下核心概念，理解这些概念将帮助您更好地使用和扩展RouterKit。

## 目录

- [路由器(Router)](Router.md)
- [路由模式(Route Pattern)](RoutePattern.md)
- [路由上下文(Route Context)](RouteContext.md)
- [拦截器(Interceptor)](Interceptor.md)
- [动画(Animation)](Animation.md)
- [模块(Module)](Module.md)

## 路由器(Router)

路由器是RouterKit的核心组件，负责管理路由注册和导航。通过全局共享实例或创建自定义实例，您可以注册路由、执行导航和管理路由状态。

## 路由模式(Route Pattern)

路由模式定义了URL路径与处理程序之间的映射关系。支持静态路径、动态参数、通配符等多种模式。

## 路由上下文(Route Context)

路由上下文包含了导航过程中的所有信息，如参数、来源、目标等。处理程序可以通过上下文获取必要的信息来创建和配置视图控制器。

## 拦截器(Interceptor)

拦截器允许您在导航过程中的不同阶段插入自定义逻辑，如权限检查、日志记录等。

## 动画(Animation)

RouterKit支持自定义导航动画，您可以为不同的路由定义不同的过渡效果。

## 模块(Module)

模块系统允许您将应用程序划分为独立的功能模块，每个模块可以注册自己的路由，实现模块化开发。