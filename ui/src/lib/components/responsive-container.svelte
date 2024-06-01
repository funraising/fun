<script lang="ts">
	import type { Snippet } from 'svelte'

	type Props = {
		children: Snippet
		class?: string
	}

	const { children, class: className = '' }: Props = $props()
</script>

<div class="responsive-container {className}">
	{#if children}
		{@render children()}
	{/if}
</div>

<style lang="postcss">
	.responsive-container {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		gap: var(--padding);
	}
</style>
