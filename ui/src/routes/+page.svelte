<script lang="ts">
    import Typography from '$lib/components/ui/typography.svelte'
    import Button from '$lib/components/ui/button.svelte'
    import { Rocket } from 'carbon-icons-svelte'
</script>

<img src="/FUNraising_transparent.png" alt="logo"/>
<Typography variant="h4">Welcome to Funraising!</Typography>
<Typography variant="large">Create your token. Raise funds. Have fun.</Typography>
<Button class="margin-top" variant="strong" href="/create"><Rocket/>Get started</Button>

<style>
    img {
        width: 192px;
        height: 192px;
        margin-bottom: 24px;
    }
    :global(.margin-top) {
        margin-top: 24px;
    }
</style>