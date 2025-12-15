import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import pkg from './package.json';

export default defineConfig({
	plugins: [sveltekit()],
	define: {
		__APP_VERSION__: JSON.stringify(pkg.version)
	},
	server: {
		host: '0.0.0.0',
		allowedHosts: ['scanopy-dev.local'],
		port: 5173,
		proxy: {
			'/api': {
				target: 'http://localhost:60072',
				changeOrigin: true
			}
		}
	},

	build: {
		outDir: 'build'
	}
});
