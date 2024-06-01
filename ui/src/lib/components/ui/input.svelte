<script lang="ts">
	import type { Snippet } from 'svelte'
	import type { HTMLInputAttributes } from 'svelte/elements'
	import { WarningAltFilled, Information, Subtract, Add } from 'carbon-icons-svelte'
	import Button from './button.svelte'
	type Layout = 'vertical' | 'horizontal'
	type Dimension = 'default' | 'large' | 'compact' | 'small'
	interface Props extends HTMLInputAttributes {
		label?: string
		labelFor?: string
		dimension?: Dimension
		layout?: Layout
		unit?: string
		error?: Snippet
		hover?: boolean
		active?: boolean
		focus?: boolean
		controls?: boolean
		disabled?: boolean
		buttons?: Snippet
	}
	let {
		label,
		labelFor = Math.random().toString(16),
		placeholder,
		value = $bindable(),
		dimension = 'default',
		layout = 'vertical',
		unit,
		error,
		hover,
		active,
		focus,
		controls,
		type,
		disabled,
		class: className = '',
		children,
		buttons,
		...restProps
	}: Props = $props()
</script>

<div class="root {layout} {dimension} {className}" class:controls>
	<label class="label" for={labelFor}>
		{label}
	</label>
	{#if children && layout === 'horizontal' && type !== 'number'}
		<div class="helper-button">
			<Information size={dimension === 'small' ? 16 : 24} />
		</div>
	{/if}
	<div class="col">
		<div class="wrapper">
			<div class="relative">
				<input
					id={labelFor}
					class:active
					class:hover
					class:focus
					class:error
					bind:value
					{placeholder}
					{type}
					{disabled}
					{...restProps}
				/>
				{#if unit && !error}
					<label class="unit" for={labelFor}>{unit}</label>
				{/if}
				{#if error}
					<label class="error-icon" for={labelFor}>
						<WarningAltFilled size={dimension === 'small' ? 16 : 24} />
					</label>
				{/if}
			</div>
			{#if controls && type === 'number'}
				<div class="control-buttons">
					<Button {dimension} {disabled} variant="secondary" onclick={() => (value -= 1)}>
						<Subtract size={dimension === 'small' ? 16 : 24} />
					</Button>
					<Button {dimension} {disabled} variant="secondary" onclick={() => (value += 1)}>
						<Add size={dimension === 'small' ? 16 : 24} />
					</Button>
				</div>
			{/if}
			{#if buttons}
				<div class="control-buttons">
					{@render buttons()}
				</div>
			{/if}
		</div>
		{#if error}
			<div class="error-message">
				{@render error()}
			</div>
		{/if}
	</div>
	{#if children && layout === 'vertical'}
		<div class="helper-text">
			{@render children()}
		</div>
	{/if}
</div>

<style lang="postcss">
	input[type='number']::-webkit-outer-spin-button,
	input[type='number']::-webkit-inner-spin-button {
		appearance: none;
	}
	input[type='number'] {
		-moz-appearance: textfield;
	}
	.vertical {
		&.root {
			display: flex;
			flex-direction: column;
		}
	}
	.horizontal {
		&.root {
			display: flex;
			flex-direction: row;
			align-items: center;
		}
	}
	.controls {
		.wrapper {
			flex-direction: row;
			gap: 0;
			input {
				border-radius: 0.25rem 0 0 0.25rem;
			}
		}
	}

	.root {
		align-self: stretch;
		gap: 0.5rem;
		color: var(--colors-ultra-high);
		font-family: var(--font-family-sans-serif);
	}
	.label {
		display: flex;
		flex-direction: column;
		cursor: pointer;
		width: fit-content;
		color: var(--colors-ultra-high);
	}
	.helper-button {
		display: flex;
		align-items: center;
		cursor: pointer;
	}
	.col {
		display: flex;
		flex-grow: 1;
		flex-direction: column;
		gap: 0.25rem;
	}
	.wrapper {
		display: flex;
		position: relative;
		flex-grow: 1;
		flex-direction: column;
		gap: 0.25rem;
		.relative {
			display: flex;
			position: relative;
			flex-grow: 1;
			flex-direction: row;
		}
		.control-buttons {
			display: flex;
			flex-direction: row;

			:global(button) {
				border-left: none;
				border-radius: 0;

				&:hover,
				&:active,
				&:focus {
					border-left: none;
				}
			}

			& > :global(*:last-child) :global(button) {
				border-radius: 0 0.25rem 0.25rem 0;
			}
		}
		input {
			flex-grow: 1;
			border: 1px solid var(--colors-ultra-high);
			border-radius: 0.25rem;
			background: transparent;
			color: var(--colors-ultra-high);
			&::placeholder {
				opacity: 0.5;
				color: var(--colors-ultra-high);
			}
			&:disabled {
				opacity: 0.25;
				cursor: not-allowed;
				& ~ .unit,
				& ~ .error-icon {
					opacity: 0.25;
					cursor: not-allowed;
				}
			}
			&:focus:not(:disabled),
			&:focus-visible:not(:disabled),
			&.focus:not(:disabled) {
				outline: 4px solid var(--colors-top);
				outline-offset: -4px;
				background: var(--colors-base);
				color: var(--colors-top);
				& ~ .unit {
					opacity: 1;
					color: var(--colors-top);
				}
			}
			&:active:not(:disabled),
			&.active:not(:disabled) {
				outline: none;
			}
			&:hover:not(:disabled),
			&.hover:not(:disabled),
			&:active:not(:disabled),
			&.active:not(:disabled) {
				border: 1px solid var(--colors-top);
				background: var(--colors-base);
				color: var(--colors-top);
			}
			&.error:not(:disabled) {
				outline: 2px solid var(--colors-top);
				outline-offset: -2px;
			}
		}
	}
	.unit {
		position: absolute;
		opacity: 0.5;
		cursor: text;
	}
	.error-icon {
		position: absolute;
		cursor: text;
		color: var(--colors-top);
	}
	.default {
		.label {
			font-size: var(--font-size);
			line-height: var(--line-height);
			letter-spacing: var(--letter-spacing);
		}
		.helper-button {
			padding: 0.75rem;
		}
		input {
			padding: 0.75rem;
			font-size: var(--font-size);
			line-height: var(--line-height);
			letter-spacing: var(--letter-spacing);
		}
		.unit {
			top: 0.75rem;
			right: 0.75rem;
			font-size: var(--font-size);
			line-height: var(--line-height);
			letter-spacing: var(--letter-spacing);
		}
		.error-icon {
			top: 0.75rem;
			right: 0.75rem;
		}
	}
	.large {
		.label {
			font-size: var(--font-size-large);
			line-height: var(--line-height-large);
			letter-spacing: var(--letter-spacing-large);
		}
		.helper-button {
			padding: 0.75rem;
		}
		input {
			padding: 0.75rem;
			font-size: var(--font-size-large);
			line-height: var(--line-height-large);
			letter-spacing: var(--letter-spacing-large);
		}
		.unit {
			top: 0.75rem;
			right: 0.75rem;
			font-size: var(--font-size-large);
			line-height: var(--line-height-large);
			letter-spacing: var(--letter-spacing-large);
		}
		.error-icon {
			top: 1rem;
			right: 0.75rem;
		}
		.error-message {
			font-size: var(--font-size-large);
			line-height: var(--line-height-large);
			letter-spacing: var(--letter-spacing-large);
		}
	}
	.compact {
		.label {
			font-size: var(--font-size);
			line-height: var(--line-height);
			letter-spacing: var(--letter-spacing);
		}
		.helper-button {
			padding: 0.5rem;
		}
		input {
			padding: 0.5rem;
			font-size: var(--font-size);
			line-height: var(--line-height);
			letter-spacing: var(--letter-spacing);
		}
		.unit {
			top: 0.5rem;
			right: 0.5rem;
			font-size: var(--font-size);
			line-height: var(--line-height);
			letter-spacing: var(--letter-spacing);
		}
		.error-icon {
			top: 0.5rem;
			right: 0.5rem;
		}
	}
	.small {
		.label {
			font-size: var(--font-size-small);
			line-height: var(--line-height-small);
			letter-spacing: var(--letter-spacing-small);
		}
		.helper-button {
			padding: 0.5rem;
		}
		input {
			padding: 0.5rem;
			font-size: var(--font-size-small);
			line-height: var(--line-height-small);
			letter-spacing: var(--letter-spacing-small);
		}
		.unit {
			top: 0.5rem;
			right: 0.5rem;
			font-size: var(--font-size-small);
			line-height: var(--line-height-small);
			letter-spacing: var(--letter-spacing-small);
		}
		.error-icon {
			top: 0.5rem;
			right: 0.5rem;
		}
		.error-message {
			font-size: var(--font-size-small);
			line-height: var(--line-height-small);
			letter-spacing: var(--letter-spacing-small);
		}
	}
	.error-message {
		border: 1px solid var(--colors-top);
		border-radius: 0.25rem;
		background: var(--colors-top);
		padding: 0.25rem 0.5rem;
		color: var(--colors-base);
		font-size: var(--font-size);
		line-height: var(--line-height);
		letter-spacing: var(--letter-spacing);
	}
	.helper-text {
		font-size: var(--font-size-small);
		line-height: var(--line-height-small);
		letter-spacing: var(--letter-spacing-small);
	}
</style>
