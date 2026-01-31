<script lang="ts">
	import { company, projects, links } from '$lib/data';
	import ContactModal from '$lib/ContactModal.svelte';

	let contactOpen = $state(false);
</script>

<main class="container">
	<!-- Hero -->
	<header class="hero">
		<h1>{company.name}</h1>
		<p class="tagline">{company.tagline}</p>
	</header>

	<!-- About -->
	<section class="about">
		<h2>What We Do</h2>
		<p>{company.about}</p>
		<ul class="services">
			{#each company.services as service}
				<li>{service}</li>
			{/each}
		</ul>
	</section>

	<!-- Portfolio Button -->
	<div class="portfolio-cta">
		<a href="https://portfolio.hatstack.fun" target="_blank" rel="noopener" class="portfolio-btn">Portfolio</a>
	</div>

	<!-- Projects -->
	<section>
		<h2>Projects</h2>
		<div class="projects-grid">
			{#each projects as project}
				<article class="project-card">
					<h3>{project.name}</h3>
					<p>{project.description}</p>
					<div class="tech">
						{#each project.tech as t}
							<span>{t}</span>
						{/each}
					</div>
					<div class="links">
						<a href={project.url} target="_blank" rel="noopener">Demo</a>
						<a href={project.github} target="_blank" rel="noopener">GitHub</a>
					</div>
				</article>
			{/each}
		</div>
	</section>

	<!-- Contact Button -->
	<div class="contact-cta">
		<button class="contact-btn" onclick={() => contactOpen = true}>Contact Us</button>
	</div>

	<!-- Links -->
	<nav class="social-links">
		{#each links as link}
			<a href={link.url} target="_blank" rel="noopener">
				{link.name}
			</a>
		{/each}
	</nav>
</main>

<footer class="container">
	<p>&copy; {new Date().getFullYear()} {company.name} · <a href="https://privacy.hatstack.fun" target="_blank" rel="noopener">Privacy</a></p>
</footer>

<ContactModal bind:open={contactOpen} />
