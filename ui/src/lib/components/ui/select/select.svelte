<script lang="ts">
	import type { HTMLInputAttributes } from 'svelte/elements'
	import { CaretDown, CaretUp } from 'carbon-icons-svelte'
	import { setContext, type Snippet } from 'svelte'
	import { withSelectStore } from './select-store.svelte'
	import Option from './option.svelte'

	type Layout = 'vertical' | 'horizontal'
	type Dimension = 'default' | 'large' | 'compact' | 'small'
	interface Props extends HTMLInputAttributes {
		helperText?: Snippet
		label?: string
		labelFor?: string
		dimension?: Dimension
		value?: string
		layout?: Layout
		hover?: boolean
		active?: boolean
		focus?: boolean
	}
	let {
		helperText,
		label,
		labelFor = Math.random().toString(16),
		dimension = 'default',
		placeholder,
		value = $bindable(),
		layout = 'vertical',
		hover,
		active,
		focus,
		class: className = '',
		children,
		...restProps
	}: Props = $props()

	let focused: boolean = $state(false)
	let input: HTMLInputElement
	let icon: HTMLButtonElement

	const store = withSelectStore(dimension, value ?? (placeholder ? '' : undefined))
	setContext('select-store', store)

	// Focused input when user clicks on caret,Unfocused input when user clicks outside input or caret
	// Close the select when user clicks outside, when user clicks on the tab button
	$effect(() => {
		function closeMenu() {
			if (store.open) store.open = false
		}
		function focus(e: MouseEvent) {
			const target = e.target as unknown as Node
			if (input?.contains(target) || icon?.contains(target)) {
				focused = true
			} else {
				focused = false
			}
		}

		function closeMenuKeyboard(e: KeyboardEvent) {
			if (e.key === 'Tab') closeMenu()
		}

		window.addEventListener('click', closeMenu)
		window.addEventListener('keydown', closeMenuKeyboard)
		window.addEventListener('mousedown', focus)

		return () => {
			window.removeEventListener('click', closeMenu)
			window.removeEventListener('keydown', closeMenuKeyboard)
			window.removeEventListener('mousedown', focus)
		}
	})

	// Update store dimension if the dimension dynamically changes
	$effect(() => {
		store.size = dimension
	})

	// Bind store value to the value prop
	$effect(() => {
		value = store.value
	})
	$effect(() => {
		if (!store.open && store.value === undefined) {
			store.marked = undefined
		} else {
			store.marked = store.value
		}
	})
</script>

<div class="root {dimension} {layout} {className}">
	<label class="label" for={labelFor}>
		{label}
	</label>
	<div class="select-container">
		<input
			bind:this={input}
			value={store.value ? store.labels[store.value] ?? store.value : value}
			class="select"
			class:hover
			class:active
			class:focus
			class:focused
			onclick={() => {
				if (!store.open)
					setTimeout(() => {
						store.open = true
					})
			}}
			onkeydown={(e) => {
				switch (e.key) {
					case 'ArrowDown': {
						e.preventDefault()
						if (!store.open) {
							store.open = true
						} else {
							const values = Object.keys(store.labels)
							const index = store.marked ? values.indexOf(store.marked) : -1
							store.marked = values[(index + 1) % values.length]
						}
						break
					}
					case 'ArrowUp': {
						e.preventDefault()
						if (!store.open) {
							store.open = true
						} else {
							const values = Object.keys(store.labels)
							const index = store.marked ? values.indexOf(store.marked) : 0
							if (index - 1 >= 0) store.marked = values[index - 1]
							else store.marked = values[values.length - 1]
						}
						break
					}
					case 'Enter': {
						e.preventDefault()
						if (!store.open) {
							store.open = true
						} else {
							store.value = store.marked
							store.open = false
						}
						break
					}
					case 'Escape': {
						if (store.open) {
							e.preventDefault()
							store.open = false
						}
					}
				}
			}}
			id={labelFor}
			{placeholder}
			readonly
			{...restProps}
		/>
		<div class="wrapper">
			<button
				bind:this={icon}
				class="icon"
				onclick={() => {
					if (!store.open) setTimeout(() => (store.open = true))
				}}
				onmouseenter={() => (hover = true)}
				onmouseleave={() => (hover = false)}
				tabindex="-1"
			>
				<div>
					{#if store.open}
						<CaretUp size={dimension === 'small' ? 16 : 24} />
					{:else}
						<CaretDown size={dimension === 'small' ? 16 : 24} />
					{/if}
				</div>
			</button>
			{#if children}
				<div class="options" class:hidden={!store.open}>
					<div>
						{#if placeholder}
							<Option class="placeholder" value="">{placeholder}</Option>
						{/if}
						{@render children()}
					</div>
				</div>
			{/if}
		</div>
	</div>
	{#if helperText && layout === 'vertical'}
		<div class="helper-text">
			{@render helperText()}
		</div>
	{/if}
</div>

<style lang="postcss">
	.vertical {
		flex-direction: column;
		align-items: stretch;
	}
	.horizontal {
		flex-direction: row;
		align-items: center;
	}
	.root {
		--transition-delay: 50ms;
		--transition: 0;
		display: flex;
		justify-content: center;
		align-self: stretch;
		gap: 0.5rem;
		color: var(--colors-ultra-high);
		font-family: var(--font-family-sans-serif);
		.select-container {
			display: flex;
			flex-grow: 1;
			flex-direction: column;
		}
	}
	.select {
		flex-grow: 1;
		appearance: none;
		cursor: pointer;
		border: 1px solid var(--colors-ultra-high);
		border-radius: 0.25rem;
		background: transparent;
		color: var(--colors-ultra-high);
		&::placeholder {
			opacity: 0.5;
			color: var(--colors-ultra-high);
		}
		&:hover:not(:disabled),
		&:hover:not(:disabled),
		&.hover:not(:disabled) {
			border: 1px solid var(--colors-top);
			background: var(--colors-low);
			color: var(--colors-top);
			& + .wrapper > button {
				color: var(--colors-top);
			}
		}
		&:active:not(:disabled),
		&.active:not(:disabled) {
			outline: none;
			border: 1px solid var(--colors-high);
			background: var(--colors-low);
			color: var(--colors-high);
			& + .wrapper > button {
				color: var(--colors-high);
			}
		}
		&:focus:not(:disabled),
		&:focus-visible:not(:disabled),
		&.focus:not(:disabled),
		&.focused:not(:disabled) {
			outline: 4px solid var(--colors-top);
			outline-offset: -4px;
			background: var(--colors-base);
			color: var(--colors-top);
			& + .wrapper > button {
				color: var(--colors-top);
			}
		}
		&:disabled {
			opacity: 0.25;
			cursor: not-allowed;
			& + .wrapper > button {
				pointer-events: none;
				div {
					opacity: 0.25;
					cursor: not-allowed;
				}
			}
		}
	}
	.label {
		cursor: pointer;
		width: fit-content;
	}
	button {
		position: absolute;
		cursor: pointer;
		margin: 0;
		outline: none;
		border: none;
		background-color: transparent;
		padding: 0;
		width: 1.5rem;
		height: 1.5rem;
		color: var(--colors-ultra-high);
	}
	.default {
		.select {
			padding: 0.75rem;
			font-size: var(--font-size);
			line-height: var(--line-height);
			letter-spacing: var(--letter-spacing);
		}
		.label {
			font-size: var(--font-size);
			line-height: var(--line-height);
			letter-spacing: var(--letter-spacing);
		}
		button {
			right: 0.75rem;
			bottom: 0.75rem;
		}
	}
	.large {
		.select {
			padding: 0.75rem;
			font-size: var(--font-size-large);
			line-height: var(--line-height-large);
			letter-spacing: var(--letter-spacing-large);
		}
		.label {
			font-size: var(--font-size-large);
			line-height: var(--line-height-large);
			letter-spacing: var(--letter-spacing-large);
		}
		button {
			right: 0.75rem;
			bottom: 1rem;
		}
	}
	.compact {
		.select {
			padding: 0.5rem;
			font-size: var(--font-size);
			line-height: var(--line-height);
			letter-spacing: var(--letter-spacing);
		}
		.label {
			font-size: var(--font-size);
			line-height: var(--line-height);
			letter-spacing: var(--letter-spacing);
		}
		button {
			right: 0.5rem;
			bottom: 0.5rem;
		}
	}
	.small {
		.select {
			padding: 0.5rem;
			font-size: var(--font-size-small);
			line-height: var(--line-height-small);
			letter-spacing: var(--letter-spacing-small);
		}
		.label {
			font-size: var(--font-size-small);
			line-height: var(--line-height-small);
			letter-spacing: var(--letter-spacing-small);
		}
		button {
			right: 0.5rem;
			bottom: 0.5rem;
			width: 1rem;
			height: 1rem;
		}
	}
	.helper-text {
		font-size: var(--font-size-small);
		line-height: var(--line-height-small);
		letter-spacing: var(--letter-spacing-small);
	}
	.wrapper {
		position: relative;
	}
	.options {
		position: absolute;
		top: 100%;
		left: 0;
		z-index: 1;
		margin-top: 0.25rem;
		border-radius: 0.25rem;
		background: var(--colors-base);
		width: 100%;

		div {
			display: flex;
			flex-direction: column;
			justify-content: stretch;
			align-items: stretch;
			border: 1px solid var(--colors-low);
			border-radius: 0.25rem;
			padding: 0.5rem;
			:global(.placeholder) {
				opacity: 0.5;
			}
		}
	}
	.hidden {
		display: none;
	}
</style>
