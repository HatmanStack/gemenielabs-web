<script lang="ts">
	import '../app.css';
	import favicon from '$lib/assets/favicon.svg';
	import { company, seo, links } from '$lib/data';

	let { children } = $props();

	const socialUrls = links.map(l => l.url);
</script>

<svelte:head>
	<!-- Basic Meta Tags -->
	<link rel="icon" href={favicon} />
	<title>{seo.title}</title>
	<meta name="description" content={seo.description} />
	<link rel="canonical" href={seo.siteUrl} />

	<!-- Open Graph Tags -->
	<meta property="og:type" content="website" />
	<meta property="og:url" content={seo.siteUrl} />
	<meta property="og:title" content={seo.title} />
	<meta property="og:description" content={seo.description} />
	<meta property="og:image" content="{seo.siteUrl}{seo.image}" />
	<meta property="og:image:width" content="1200" />
	<meta property="og:image:height" content="630" />
	<meta property="og:image:alt" content="{company.name} - {company.tagline}" />
	<meta property="og:locale" content="en_US" />
	<meta property="og:site_name" content={company.name} />

	<!-- Twitter Card Tags -->
	<meta name="twitter:card" content="summary_large_image" />
	<meta name="twitter:site" content={seo.twitterHandle} />
	<meta name="twitter:creator" content={seo.twitterHandle} />
	<meta name="twitter:title" content={seo.title} />
	<meta name="twitter:description" content={seo.description} />
	<meta name="twitter:image" content="{seo.siteUrl}{seo.image}" />
	<meta name="twitter:image:alt" content="{company.name} - {company.tagline}" />

	<!-- JSON-LD Structured Data -->
	{@html `<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "${company.name}",
  "url": "${seo.siteUrl}",
  "logo": "${seo.siteUrl}/favicon.svg",
  "description": "${seo.description}",
  "sameAs": ${JSON.stringify(socialUrls)},
  "knowsAbout": [
    "Mobile App Development",
    "AI/ML Integration",
    "Cloud Architecture",
    "React Native",
    "AWS",
    "Generative AI"
  ]
}
</script>`}
</svelte:head>

{@render children()}
