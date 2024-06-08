### 前端选型

有很多优秀的管理端前端框架，我这里找到一个优秀的开源的项目，基本可以满足CodePod的需求

	https://gitee.com/lyt-top/vue-next-admin.git

> 简介：

	基于 vue3.x + CompositionAPI setup 语法糖 + typescript + vite + element plus + vue-router-next + pinia 技术，
    适配手机、平板、pc 的后台开源免费模板，希望减少工作量，帮助大家实现快速开发


### CodePod 网站配置

	src/stores/themeConfig.ts

```javascript
export const useThemeConfig = defineStore('themeConfig', {
	state: (): ThemeConfigState => ({
		themeConfig: {
			// 是否开启布局配置抽屉
			isDrawer: false,

			/**
			 * 全局主题
			 */
			// 默认 primary 主题颜色
			primary: '#409eff',
			// 是否开启深色模式
			isIsDark: false,

			/**
             * 这里省略配置内容，视情况酌情修改...
             * /

			/**
			 * 全局网站标题 / 副标题
			 */
			// 网站主标题（菜单导航、浏览器当前网页标题）
			globalTitle: '云工作空间',
			// 网站副标题（登录页顶部文字）
			globalViceTitle: 'Code Pod 云工作空间（体验版）',
			// 网站副标题（登录页顶部文字）
			globalViceTitleMsg: 'Web IDE、一键启动、快速开发',
			// 默认初始语言，可选值"<zh-cn|en|zh-tw>"，默认 zh-cn
			globalI18n: 'zh-cn',
			// 默认全局组件大小，可选值"<large|'default'|small>"，默认 'large'
			globalComponentSize: 'large',
		},
	}),
	actions: {
		setThemeConfig(data: ThemeConfigState) {
			this.themeConfig = data.themeConfig;
		},
	},
});


```

### GraphQL Client

技术选型采用`GraphQL`接口协议，前端需要集成GraphQL Client配置，这里采用`Apollo GraphQL`前端框架。

> 参考地址

	https://www.apollographql.com/docs/react/get-started

> 安装

	npm install @apollo/client graphql


### JWT

> 安装

	npm install jwt-decode


### 接口定义

#### 公共方法

统一配置客户端、统一解析Token及Header、统一处理错误等

	src/api/apollo/common/index.ts

```javascript
import { Session } from '/@/utils/storage';
import jwtDecode from 'jwt-decode';

import { ApolloClient, createHttpLink, InMemoryCache, ApolloLink, from } from '@apollo/client/core';
import { setContext } from '@apollo/client/link/context';
import { provideApolloClient, useQuery, useMutation } from '@vue/apollo-composable';
import { onError } from '@apollo/client/link/error';
import { ElMessage } from 'element-plus';
import Cookies from 'js-cookie';

const httpLinkUser = createHttpLink({
	uri: import.meta.env.VITE_API_URL + 'api/user/graphql',
});

const httpLinkWorkspce = createHttpLink({
	uri: import.meta.env.VITE_API_URL + 'api/workspace/graphql',
});

// 缓存实现
const cache = new InMemoryCache();

const authContext = setContext(async (_, { headers }) => {
	return {
		headers: {
			...headers,
			Authorization: getToken(),
			RefreshToken: getRefreshToken(),
			orgId: getUserOrgId(),
			projectId: getProjectId(),
		},
	};
});

// 统一处理错误
const errorLink = onError(({ graphQLErrors, networkError }) => {
	if (graphQLErrors)
		graphQLErrors.forEach(({ message, locations, path }) => {
			console.log(`[GraphQL error]: Message: ${message}, Location: ${locations}, Path: ${path}`);
			let msg = JSON.parse(message);
			ElMessage.warning('[' + msg.code + ']' + msg.message);
		});
	if (networkError) {
		console.error(`[Network error]: ${networkError}`);
		ElMessage.warning('抱歉，网络异常');
	}
});

// 统一处理响应的Token
const responseLink = new ApolloLink((operation, forward) => {
	return forward(operation).map((response) => {
		const context = operation.getContext();
		const responseHeaders = context.response.headers;
		let token = responseHeaders.get('Authorization');
		if (token) {
			Session.set('Authorization', token);
			Cookies.set('Authorization', token);
		}
		return response;
	});
});

// 创建 apollo 客户端
const client = new ApolloClient({
	link: from([
		errorLink,
		responseLink,
		authContext.concat(
			ApolloLink.split(
				(operation) => {
					return operation.getContext().clientName === 'user';
				},
				httpLinkUser,
				httpLinkWorkspce
			)
		),
	]),
	cache,
});

provideApolloClient(client);

const getToken = () => {
	let value = Session.get('Authorization');
	value = value ? value : '';
	return value;
};

const getRefreshToken = () => {
	let token = Session.get('Authorization');
	let refreshToken = '';
	if (token) {
		//判断token是否过期，过期获取 refresh token
		//不考虑前端设备修改时间的情况，后端也会进行校验
		const payload: any = jwtDecode(token);
		let exp = payload.exp;
		let now = new Date().getTime() / 1000;
		if (now - exp >= 0) {
			refreshToken = Session.get('RefreshToken');
		}
	}
	return refreshToken;
};

const getUserOrgId = () => {
	let value = Session.get('orgId');
	value = value ? value : '';
	return value;
};

const getProjectId = () => {
	let value = Session.get('projectId');
	value = value ? value : '';
	return value;
};

export { useQuery, useMutation };

```

#### 用户接口

	src/api/apollo/user/index.ts

```javascript
import gql from 'graphql-tag';
import { useQuery } from '/@/api/apollo/common';

const userQuery = () => {
	const { query: userQuery, onResult } = useQuery(
		gql`
			query {
				result: user {
					uuid
					screenName
					profile
				}
			}
		`,
		null,
		{
			fetchPolicy: 'no-cache',
			context: {
				clientName: 'user',
			},
		}
	);

	return {
		userQuery,
		onResult,
	};
};

const userApi = {
	userInfo: userQuery,
};

export { userApi };


```

#### 接口调用

```javascript
import { userApi } from '/@/api/apollo/user';

userApi.userInfo().onResult((e) => {

    //处理逻辑
});

```