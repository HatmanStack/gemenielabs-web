<script lang="ts">
	let { open = $bindable(false) } = $props();

	let name = $state('');
	let email = $state('');
	let message = $state('');
	let sending = $state(false);
	let sent = $state(false);
	let error = $state('');

	const API_URL = import.meta.env.VITE_CONTACT_API_URL || '';

	async function handleSubmit(e: Event) {
		e.preventDefault();
		if (!name || !email || !message) return;

		sending = true;
		error = '';

		try {
			const res = await fetch(API_URL, {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ name, email, message }),
			});

			if (!res.ok) throw new Error('Failed to send');

			sent = true;
			name = '';
			email = '';
			message = '';
		} catch (_e) {
			error = 'Failed to send message. Please try again.';
		} finally {
			sending = false;
		}
	}

	function close() {
		open = false;
		sent = false;
		error = '';
	}

	function handleKeydown(e: KeyboardEvent) {
		if (e.key === 'Escape') close();
	}
</script>

<svelte:window onkeydown={handleKeydown} />

{#if open}
	<!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions -->
	<div class="overlay" onclick={close}>
		<!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions -->
		<div class="modal" onclick={(e) => e.stopPropagation()}>
			<button class="close-btn" onclick={close}>&times;</button>

			{#if sent}
				<div class="success">
					<h2>Message Sent</h2>
					<p>Thanks for reaching out. We'll get back to you soon.</p>
					<button class="btn" onclick={close}>Close</button>
				</div>
			{:else}
				<h2>Get in Touch</h2>
				<form onsubmit={handleSubmit}>
					<label>
						Name
						<input type="text" bind:value={name} required />
					</label>
					<label>
						Email
						<input type="email" bind:value={email} required />
					</label>
					<label>
						Message
						<textarea bind:value={message} rows="4" required></textarea>
					</label>
					{#if error}
						<p class="error">{error}</p>
					{/if}
					<button class="btn" type="submit" disabled={sending}>
						{sending ? 'Sending...' : 'Send Message'}
					</button>
				</form>
			{/if}
		</div>
	</div>
{/if}

<style>
	.overlay {
		position: fixed;
		inset: 0;
		background: rgba(0, 0, 0, 0.8);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 100;
		padding: 1rem;
	}

	.modal {
		background: #141414;
		border: 1px solid #262626;
		border-radius: 12px;
		padding: 2rem;
		width: 100%;
		max-width: 400px;
		position: relative;
	}

	.close-btn {
		position: absolute;
		top: 1rem;
		right: 1rem;
		background: none;
		border: none;
		color: #737373;
		font-size: 1.5rem;
		cursor: pointer;
		line-height: 1;
	}

	.close-btn:hover {
		color: #e5e5e5;
	}

	h2 {
		margin-bottom: 1.5rem;
		font-size: 1.25rem;
		color: #e5e5e5;
	}

	form {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	label {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
		font-size: 0.875rem;
		color: #737373;
	}

	input, textarea {
		background: #0a0a0a;
		border: 1px solid #262626;
		border-radius: 6px;
		padding: 0.75rem;
		color: #e5e5e5;
		font-size: 1rem;
		font-family: inherit;
	}

	input:focus, textarea:focus {
		outline: none;
		border-color: #3b82f6;
	}

	textarea {
		resize: vertical;
		min-height: 100px;
	}

	.btn {
		background: #3b82f6;
		color: white;
		border: none;
		border-radius: 6px;
		padding: 0.75rem 1.5rem;
		font-size: 1rem;
		cursor: pointer;
		margin-top: 0.5rem;
	}

	.btn:hover:not(:disabled) {
		background: #2563eb;
	}

	.btn:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.error {
		color: #ef4444;
		font-size: 0.875rem;
	}

	.success {
		text-align: center;
	}

	.success p {
		color: #737373;
		margin-bottom: 1.5rem;
	}
</style>
