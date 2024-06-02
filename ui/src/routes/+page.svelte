<script lang="ts">
    import Typography from '$lib/components/ui/typography.svelte'
    import Button from '$lib/components/ui/button.svelte'
    import { Rocket } from 'carbon-icons-svelte'
</script>

<div class="spacer"></div>
<div class="spacer"></div>
<div class="spacer"></div>
<div class="spacer"></div>

<img src="/FUNraising_transparent.png" alt="logo"/>
<Typography variant="h4">Welcome to Funraising!</Typography>
<Typography variant="large">Create your token. Raise funds. Have fun.</Typography>
<Button class="margin-top" variant="strong" href="/create/1"><Rocket/>Get started</Button>

<style>
    img {
        width: 384px;
        height: 384px;
        margin-bottom: 24px;
    }
    .spacer {
        margin-bottom: var(--padding);
    }
    :global(.margin-top) {
        margin-top: 24px;
    }
</style>