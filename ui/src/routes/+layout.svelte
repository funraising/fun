<script lang="ts">
    import '../app.pcss'
    import '../diete.css'

    let { children } = $props()
</script>

<div class="centered">
    {#if children}
        {@render children()}
    {/if}
</div>

<style>
    .centered {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        width: 100%;
        height: 100%;
        gap: var(--half-padding);
        min-width: 50vw;
        min-height: 50vh;
    }
</style>
