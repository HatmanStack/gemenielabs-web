<script lang="ts">
	import '../app.css';
	import favicon from '$lib/assets/favicon.svg';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<title>Gemenie Labs | Mobile & Web Applications Powered by AI</title>
	<meta name="description" content="Building mobile and web applications with AI, cloud, and modern frameworks" />
</svelte:head>

{@render children()}
