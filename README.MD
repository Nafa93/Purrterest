<h1> PURRTEREST </h1>

<h5> Thought Process </h5>

My first thoughts when looking at https://cataas.com/ and playing around with it for a little bit was to build something like pinterest.

I saw that all images have different sizes so pinterest’s uneven height grid layout would be great to display something like this.

It’s advantages are that it supports different height so pictures both portrait and landscape pictures will be displayed perfectly without cropping any content.

Since this is more visual than data heavy I will try to focus on things like layout.

In terms of functionality I’ll make an infinite scroll home tab that will be fetching images while the user scrolls, maybe pre-fetching them to make it more seamless.

The user will be able to tap on the any image ans the image is displayed at the top and then after a divider a subset of images will be displayed.
I’m not much of a pinterest user but I think that every time you tap into an image, a few similar images will be suggested so I plan to make use of the tags that the API provides to display these suggestions.

Users will be able to save content which will be displayed on a different tab. To make it more user friendly I think it will be nice to store these ones in core data so the user has them available at any time.

For the home view I think in memory caching should be enough.
